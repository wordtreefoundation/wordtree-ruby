#include <ruby.h>
#include <ruby/encoding.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

// for rubinius
#ifndef rb_enc_fast_mbclen
#   define rb_enc_fast_mbclen rb_enc_mbclen
#endif

static rb_encoding* u8_enc;
static rb_encoding* bin_enc;

/** Transforms text such as the following:
 *
 *   And behold, I said, "This is no good!"
 *   What shall ye say unto these people, there-
 *   fore?
 *
 * Into a cleaned up single line of text, like the following:
 *
 *   and behold i said this is no good.what shall ye say unto these people therefore.
 *
 * Spaces indicate word boundaries, while periods indicate sentence boundaries.
 */
size_t text_clean_cstr(char* text)
{
  if (*text == '\0') return 0;

  char* read;
  char* write = text;
  uint8_t join_lines = false,
          just_added_space = true,   // prevent prefix spaces
          just_added_period = false;
  for (read=text; *read; read++) {
    char c = *read;
    if (c >= 'A' && c <= 'Z') {
      // Change upper case to lowercase
      c += 32;
    } else if (c == '\n') {
      // Change newlines to spaces (i.e. both count as whitespace)
      c = ' ';
    } else if (c == '?' || c == '!') {
      // Change exclamation, question marks to periods (i.e. sentence boundaries)
      c = '.';
    }

    if (c == '-') {
      join_lines = true;
    } else if (join_lines && c == ' ') {
      // ignore whitespace after a dash (i.e. including newlines, which is the
      // most common case because words that are broken by syllables are dashed)
    } else if (c == '.' && !just_added_period) {
      // erase space before period
      if (just_added_space) write--;
      *write++ = '.';
      just_added_period = true;
      just_added_space = false;
      join_lines = false;
    } else if (c == ' ' && !just_added_space && !just_added_period) {
      *write++ = ' ';
      just_added_space = true;
      just_added_period = false;
    } else if (c >= 'a' && c <= 'z') {
      *write++ = c;
      just_added_space = false;
      just_added_period = false;
      join_lines = false;
    }
  }
  // erase space at end of text
  if (just_added_space) write--;

  // Return the new length of the string
  return (size_t)(write - text);
}

static VALUE text_common_trigrams(VALUE self, VALUE text) {
  char* ptext = RSTRING_PTR(text);
  long len = RSTRING_LEN(text);

  if (len < 3) return INT2NUM(0);

  /* 28 most common English trigrams, all squished together */
  char common_trigrams[] = "allandedtentereforhashatherhisingionithmenncendeoftsthterthathethitiotisverwaswityou";

  char* ptr = ptext;
  char* tail = ptext + len;
  int i = 0, common_matched = 0;
  while (ptr < tail) {
    for (i = 0; i < sizeof(common_trigrams); i += 3) {
      if (memcmp(ptr, common_trigrams + i, 3) == 0) {
        common_matched++;
        break;
      }
    }
    ptr++;
  }

  return INT2NUM(common_matched);
}

static VALUE text_clean(VALUE self, VALUE text) {
    rb_str_modify(text);

    char* ctext = StringValueCStr(text);
    size_t new_length = text_clean_cstr(ctext);

    rb_str_set_len(text, (long)new_length);

    return text;
}

static inline void _incr_value(
  VALUE hash,   // Hash
  VALUE key,    // String
  VALUE suffix, // Symbol or nil
  VALUE incr_existing_keys_only) // true/false
{
  // rb_funcall(rb_mKernel, rb_intern("p"), 4, hash, key, suffix, incr_existing_keys_only);
  if (suffix == Qnil) {
    // We know the hash is shallow, and has just integer values
    VALUE val = rb_hash_lookup(hash, key);
    if (val != Qnil) {
      // Increment the key's value by 1
      rb_hash_aset(hash, key, INT2FIX(FIX2INT(val) + 1));
    } else if (!RTEST(incr_existing_keys_only)) {
      // Add this key and start the value at 1
      rb_hash_aset(hash, key, INT2FIX(1));
    }
  } else {
    // The hash contains a hash
    VALUE inner_hash = rb_hash_lookup(hash, key);
    if (inner_hash != Qnil) {
      Check_Type(inner_hash, T_HASH);
      VALUE val = rb_hash_lookup(inner_hash, suffix);
      if (val == Qnil) {
        // Start this key.suffix's value at 1
        rb_hash_aset(inner_hash, suffix, INT2FIX(1));
      } else {
        // Increment the key.suffix's value by 1
        rb_hash_aset(inner_hash, suffix, INT2FIX(FIX2INT(val) + 1));
      }
    } else if (!RTEST(incr_existing_keys_only)) {
      // Create an inner hash for this key (to contain suffixes)
      inner_hash = rb_hash_new();
      rb_hash_aset(inner_hash, suffix, INT2FIX(1));
      // Add suffix inner_hash to this key
      rb_hash_aset(hash, key, inner_hash);
    }
  }
}

VALUE text_incr_value(VALUE self, VALUE hash, VALUE key, VALUE suffix, VALUE incr_existing_keys_only)
{
  Check_Type(hash, T_HASH);
  Check_Type(key, T_STRING);
  if (suffix != Qnil) Check_Type(suffix, T_SYMBOL);

  _incr_value(hash, key, suffix, incr_existing_keys_only);
  return self;
}

VALUE text_add_ngrams_with_suffix(
  VALUE self,
  VALUE text,
  VALUE hash,
  VALUE upto_n_value,
  VALUE suffix,
  VALUE incr_existing_keys_only)
{
  char* head = RSTRING_PTR(text);
  char* tail = RSTRING_PTR(text);
  char* next_head = head;
  char* next_tail = tail;
  int word_count = 0;
  int text_len = RSTRING_LEN(text);
  int incr_existing = RTEST(incr_existing_keys_only);
  int upto_n = FIX2INT(upto_n_value);

  if (text_len == 0) return self;

  do {
    if (*tail == ' ' || *tail == '.' || tail >= head+text_len) {
      word_count++;
      if (word_count == 1 || upto_n == 1) {
        next_head = next_tail = tail + 1;
      } else if (word_count == 2) {
        next_tail = tail;
      }
      if (word_count <= upto_n) {
        _incr_value(hash, rb_str_new(head, tail - head), suffix, incr_existing_keys_only);
      }
      if (word_count == upto_n) {
        head = next_head;
        tail = next_tail;
        word_count = 0;
      } else {
        tail++;
      }
    } else {
      tail++;
    }
  } while(*tail);

  // add the last ngram of size upto_n
  _incr_value(hash, rb_str_new(head, tail - head), suffix, incr_existing_keys_only);

  // add the 1..(upto_n-1) sized ngrams at the tail
  if (upto_n > 1) {
    while(head < RSTRING_PTR(text)+text_len) {
      if(*head == ' ' || *head == '.') {
        _incr_value(hash, rb_str_new(head + 1, tail - head - 1), suffix, incr_existing_keys_only);
      }
      head++;
    }
  }

  return self;
}

extern "C"
void Init_wordtree() {
    VALUE rb_mWordTree = rb_define_module("WordTree");
    VALUE rb_mText = rb_define_module_under(rb_mWordTree, "Text");

    u8_enc = rb_utf8_encoding();
    bin_enc = rb_ascii8bit_encoding();

    rb_define_module_function(rb_mText, "clean", RUBY_METHOD_FUNC(text_clean), 1);
    rb_define_module_function(rb_mText, "common_trigrams", RUBY_METHOD_FUNC(text_common_trigrams), 1);
    rb_define_module_function(rb_mText, "incr_value", RUBY_METHOD_FUNC(text_incr_value), 4);
    rb_define_module_function(rb_mText, "_add_ngrams_with_suffix", RUBY_METHOD_FUNC(text_add_ngrams_with_suffix), 5);
}
