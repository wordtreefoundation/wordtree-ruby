require 'spec_helper'
require 'wordtree/text'
require 'timeout'

describe WordTree::Text do
  context "#split_near" do
    it "splits on spaces" do
      line, rem = WordTree::Text.split_near("it is near", 7)
      expect(line).to eq("it is")
      expect(rem).to eq("near")
    end

    it "removes a space if index lands on one" do
      line, rem = WordTree::Text.split_near("it is near", 5)
      expect(line).to eq("it is")
      expect(rem).to eq("near")
    end

    it "keeps the whole line if index is >= length of line" do
      line, rem = WordTree::Text.split_near("it is near", 10)
      expect(line).to eq("it is near")
      expect(rem).to eq("")

      line, rem = WordTree::Text.split_near("it is near", 11)
      expect(line).to eq("it is near")
      expect(rem).to eq("")
    end

    it "splits at the index anyway if no spaces are found" do
      line, rem = WordTree::Text.split_near("itisnear", 4)
      expect(line).to eq("itis")
      expect(rem).to eq("near")
    end
  end

  context "#clean" do
    it "wraps" do
      sample_text = "This, [here]  is awesome, right"
      cleaned = WordTree::Text.clean(sample_text)
      expect(cleaned).to eq("this here is awesome right")
    end

    it "joins lines ending in -" do
      sample_text = "What-\never\ndo you\n mean?"
      cleaned = WordTree::Text.clean_text(sample_text)
      expect(cleaned).to eq("whatever do you mean.")
    end

    it "does not ignore sentence boundaries" do
      sample_text = "This is a sentence. And so is this? Keep the dots."
      cleaned = WordTree::Text.clean_text(sample_text)
      expect(cleaned).to eq("this is a sentence.and so is this.keep the dots.")
    end

    it "compresses sentence boundary punctuation and spaces" do
      sample_text = "words . . and.. stuff"
      cleaned = WordTree::Text.clean_text(sample_text)
      expect(cleaned).to eq("words.and.stuff")
    end
  end
end
