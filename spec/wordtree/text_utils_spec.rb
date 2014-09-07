require 'spec_helper'
require 'wordtree/text_utils'

describe WordTree::TextUtils do
  context "#split_near" do
    it "splits on spaces" do
      line, rem = WordTree::TextUtils.split_near("it is near", 7)
      expect(line).to eq("it is")
      expect(rem).to eq("near")
    end

    it "removes a space if index lands on one" do
      line, rem = WordTree::TextUtils.split_near("it is near", 5)
      expect(line).to eq("it is")
      expect(rem).to eq("near")
    end

    it "keeps the whole line if index is >= length of line" do
      line, rem = WordTree::TextUtils.split_near("it is near", 10)
      expect(line).to eq("it is near")
      expect(rem).to eq("")

      line, rem = WordTree::TextUtils.split_near("it is near", 11)
      expect(line).to eq("it is near")
      expect(rem).to eq("")
    end

    it "splits at the index anyway if no spaces are found" do
      line, rem = WordTree::TextUtils.split_near("itisnear", 4)
      expect(line).to eq("itis")
      expect(rem).to eq("near")
    end
  end

  context "#clean_text" do
    it "wraps" do
      sample_text = "This, [here]  is awesome, right"
      cleaned = WordTree::TextUtils.clean_text(sample_text, 10)
      expect(cleaned).to eq("this here\nis awesome\nright\n")

      cleaned = WordTree::TextUtils.clean_text(sample_text, 15)
      expect(cleaned).to eq("this here is\nawesome right\n")

      cleaned = WordTree::TextUtils.clean_text(sample_text, 150)
      expect(cleaned).to eq("this here is awesome right\n")
    end

    it "joins lines ending in -" do
      sample_text = "What-\never\ndo you\n mean?"
      cleaned = WordTree::TextUtils.clean_text(sample_text, 10)
      expect(cleaned).to eq("whatever\ndo you\nmean .\n")
    end

    it "does not ignore sentence boundaries" do
      sample_text = "This is a sentence. And so is this? Keep the dots."
      cleaned = WordTree::TextUtils.clean_text(sample_text, 150)
      expect(cleaned).to eq("this is a sentence . and so is this . keep the dots .\n")
      cleaned = WordTree::TextUtils.clean_text(sample_text, 10)
      expect(cleaned).to eq("this is a\nsentence .\nand so is\nthis .\nkeep the\ndots .\n")
    end

    it "compresses sentence boundary punctuation and spaces" do
      sample_text = "words . . and.. stuff"
      cleaned = WordTree::TextUtils.clean_text(sample_text, 150)
      expect(cleaned).to eq("words . and . stuff\n")
    end
  end

  context "#each_ngram" do
    it "yields ngrams in succession" do
      sample_text = "one word\n. two\n"
      expect{ |b| WordTree::TextUtils.each_ngram(sample_text, 1, &b) }.to \
        yield_successive_args("one", "word", ".", "two")
      expect{ |b| WordTree::TextUtils.each_ngram(sample_text, 2, &b) }.to \
        yield_successive_args("one word", "word .", ". two")
      expect{ |b| WordTree::TextUtils.each_ngram(sample_text, 3, &b) }.to \
        yield_successive_args("one word .", "word . two")
    end
  end
end
