require 'strscan'
require_relative "../../ext/wordtree"

module WordTree
  module Text
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
    def self.word_wrap(input, wrap=120)
      output_line = String.new
      wrapped_output = String.new
      begin
        output_line, remainder = split_near(input, wrap)
        wrapped_output << output_line + "\n"
        output = remainder
      end while remainder.size > wrap
      wrapped_output << remainder + "\n" unless remainder.empty?

      return wrapped_output
    end

  end
end