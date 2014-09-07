require 'virtus'
require 'simhash'

require 'wordtree/text_utils'

module WordTree
  class Book
    include Virtus.model

    attribute :id, String, :default => :default_id
    attribute :archive_org_id, String
    attribute :title, String
    attribute :author, String
    attribute :year, Integer
    attribute :source, String
    attribute :status, String
    # Size of the content in bytes
    attribute :size_bytes, Integer, :default => :content_size
    # A simhash (locality-sensitive hash) of the content
    attribute :simhash, Integer

    attribute :content, String

    def initialize(*args)
      super
      @ngrams = {}
    end

    def self.create(id, metadata, content)
      new(metadata.merge("id" => id, "content" => content))
    end

    def default_id
      archive_org_id
    end

    def metadata
      attributes.select{ |k,v| !v.nil? && k != :content }
    end

    def content_clean(wrap=120)
      if @content_clean_wrap != wrap
        # Memoize content_clean (using last wrap size)
        @content_clean_wrap = wrap
        @content_clean = TextUtils.clean_text(content, wrap)
      end
      @content_clean
    end

    def content_size
      content ? content.size : nil
    end

    def each_ngram(n=1, &block)
      TextUtils.each_ngram(content_clean, n, &block)
    end

    def set_ngrams(n, lookup)
      raise ArgumentError, "must be a Hash" unless lookup.is_a?(Hash)
      @ngrams[n] = lookup
    end

    def ngrams(n=1)
      # Memoize ngram counts
      @ngrams[n] ||= count_ngrams(n)
    end

    def all_ngrams
      @ngrams
    end

    def count_ngrams(n=1)
      {}.tap do |tally|
        each_ngram(n) do |ngram|
          tally[ngram] ||= 0
          tally[ngram] += 1
        end
      end
    end

    def calculate_simhash
      content ? content_clean.simhash(:split_by => /\s/) : nil
    end
  end
end