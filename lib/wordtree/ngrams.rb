module WordTree
  class Ngrams
    def initialize
      @trie = Trie.new
    end

    def inc(ngram)
      value = @trie.get(ngram) || 0
      @trie.set(ngram, value + 1)
    end
  end
end