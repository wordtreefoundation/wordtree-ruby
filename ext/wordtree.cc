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

static VALUE text_clean(VALUE self, VALUE text) {
    rb_str_modify(text);

    char* ctext = StringValueCStr(text);
    size_t new_length = text_clean_cstr(ctext);

    rb_str_set_len(text, (long)new_length);

    return text;
}

extern "C"
void Init_wordtree() {
    VALUE rb_mWordTree = rb_define_module("WordTree");
    VALUE rb_mText = rb_define_module_under(rb_mWordTree, "Text");

    u8_enc = rb_utf8_encoding();
    bin_enc = rb_ascii8bit_encoding();

    rb_define_module_function(rb_mText, "clean", RUBY_METHOD_FUNC(text_clean), 1);
}
