require 'strscan'

module WordTree
  module TextUtils
    def self.split_near(text, split_index)
      if split_index >= text.size
        return [text, ""]
      else
        index = split_index
        while index >= 0
          if text[index] == ' '
            return [text[0...index], text[(index+1)..-1]]
          end
          index -= 1
        end
        return [text[0...split_index], text[split_index..-1]]
      end
    end

    # Remove punctuation an non-alphabetical characters from a text, and return
    # a cleaned-up version wrapped at +wrap+ characters per line.

    def self.clean_text(input, wrap=120)
      join = nil
      output = String.new
      output_line = String.new

      # Ignore non-UTF-8 characters
      input = input.encode('UTF-8', :invalid => :replace, :undef => :replace).downcase

      _0 = '0'.ord
      _9 = '9'.ord
      _a = 'a'.ord
      _z = 'z'.ord
      _A = 'A'.ord
      _Z = 'Z'.ord
      _dash = '-'.ord
      _space = ' '.ord
      _newline = "\n".ord
      _period = '.'.ord
      _question = '?'.ord

      join_lines = false
      just_added_space = false
      just_added_period = false
      line_length = 0
      input.each_char do |c|
        c = c.ord
        # Change upper-case to lower-case
        c -= 32 if (c >= _A && c <= _Z)
        # Change newlines to spaces
        c = _space if c == _newline
        # Change question marks to periods (i.e. both count as sentence boundaries)
        c = _period if c == _question

        if c == _dash
          # In case of a dash, set the scoop-spaces-up flag
          join_lines = true
        elsif join_lines && (c == _space)
          # ignore
        elsif (c == _period) && !just_added_period
          if !just_added_space
            output << _space.chr
          end
          output << c.chr
          just_added_period = true
          just_added_space = true
        elsif (c >= _a && c <= _z) || (c == _space && !just_added_space)
          # Add letters and spaces
          output << _space.chr if just_added_period
          output << c.chr
          line_length += 1
          just_added_space = (c == _space)
          just_added_period = false
          join_lines = false
        end
      end

      wrapped_output = String.new
      begin
        output_line, remainder = split_near(output, wrap)
        wrapped_output << output_line + "\n"
        output = remainder
      end while remainder.size > wrap
      wrapped_output << remainder + "\n" unless remainder.empty?

      return wrapped_output
    end
    
    # ** Chris' C Code Version of the above **
    # 
    # # Credit: "most efficient way to remove special characters from string" By Guffa 
    # #  http://stackoverflow.com/questions/1120198/most-efficient-way-to-remove-special-characters-from-string
    # #
    # # How fast is this code?
    # #
    # # Regular expression: 294.4 ms.
    # # Original function: 54.5 ms.
    # # My suggested change: 47.1 ms.
    # # Mine with setting StringBuilder capacity: 43.3 ms.
    # # I tested the lookup+char[] solution, and it runs in about 13 ms.
    #
    #private static bool[] _lookup;
    #static Program() {
    # _lookup = new bool[65535];
    # for (char c = '0'; c <= '9'; c++) _lookup[c] = true;
    # for (char c = 'A'; c <= 'Z'; c++) _lookup[c] = true;
    # for (char c = 'a'; c <= 'z'; c++) _lookup[c] = true;
    # _lookup['.'] = true;
    # _lookup['_'] = true;
    #}
    #public static string RemoveSpecialCharacters(string str) {
    # char[] buffer = new char[str.Length];
    # int index = 0;
    # foreach (char c in str) {
    #   if (_lookup[c]) {
    #      buffer[index] = c;
    #      index++;
    #   }
    # }
    # return new string(buffer, 0, index);
    #}    

    def self.each_ngram(input, n=1, &block)
      onegram_re = /([^ \n]+[ \n])/
      ngram_re = /([^ \n]+[ \n]){#{n},#{n}}/
      s = StringScanner.new(input)
      while !s.eos?
        if words = s.scan(ngram_re)
          yield words.rstrip.tr("\n", " ") if block_given?
          # Move back to beginning of n-word sequence
          s.unscan
        end
        # Move forward one word
        if !s.scan(onegram_re)
          # if we can't find a word, let's try to recover by scanning one char at a time
          s.scan(/./m)
        end
      end
    end
  end
end
