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

  describe "#clean" do
    it "wraps" do
      sample_text = "This, [here]  is awesome, right"
      cleaned = WordTree::Text.clean(sample_text)
      expect(cleaned).to eq("this here is awesome right")
    end

    it "joins lines ending in -" do
      sample_text = "What-\never\ndo you\n mean?"
      cleaned = WordTree::Text.clean(sample_text)
      expect(cleaned).to eq("whatever do you mean.")
    end

    it "does not ignore sentence boundaries" do
      sample_text = "This is a sentence. And so is this? Keep the dots."
      cleaned = WordTree::Text.clean(sample_text)
      expect(cleaned).to eq("this is a sentence.and so is this.keep the dots.")
    end

    it "compresses sentence boundary punctuation and spaces" do
      sample_text = "words . . and.. stuff"
      cleaned = WordTree::Text.clean(sample_text)
      expect(cleaned).to eq("words.and.stuff")
    end
  end

  describe "#common_trigrams" do
    it "returns 0 for strings of len < 3" do
      expect(WordTree::Text.common_trigrams("")).to eq 0
      expect(WordTree::Text.common_trigrams("1")).to eq 0
      expect(WordTree::Text.common_trigrams("12")).to eq 0
    end

    it "returns 0 for strings without common trigrams" do
      expect(WordTree::Text.common_trigrams("!{*@*!()}")).to eq 0
      expect(WordTree::Text.common_trigrams("qwrtypzzx")).to eq 0
      expect(WordTree::Text.common_trigrams("         ")).to eq 0
    end

    it "returns correct counts for strings with trigrams" do
      expect(WordTree::Text.common_trigrams("what")).to eq 1
      expect(WordTree::Text.common_trigrams("the wall")).to eq 2
    end
  end

  describe "#incr_value" do
    context "existing keys only" do
      it "does not add keys" do
        hash = {"hello" => 1}
        WordTree::Text.incr_value(hash, "goodbye", nil, true)
        expect(hash.size).to eq 1
        expect(hash).to_not have_key("goodbye")
      end

      it "creates suffixes to existing keys" do
        hash = {"hello" => {}}
        WordTree::Text.incr_value(hash, "hello", :greeting, true)
        expect(hash.size).to eq 1
        expect(hash["hello"]).to be_a(Hash)
        expect(hash["hello"][:greeting]).to eq 1
      end

      it "adds values for suffixes to existing keys" do
        hash = {"hello" => {:greeting => 1}}
        WordTree::Text.incr_value(hash, "hello", :greeting, true)
        WordTree::Text.incr_value(hash, "hello", :other, true)
        expect(hash.size).to eq 1
        expect(hash["hello"]).to eq(:greeting => 2, :other => 1)
      end
    end

    context "open ended keys" do
      it "adds keys" do
        hash = {}
        WordTree::Text.incr_value(hash, "hello", nil, false)
        expect(hash).to eq("hello" => 1)
      end

      it "adds key and suffix" do
        hash = {}
        WordTree::Text.incr_value(hash, "hello", :greeting, false)
        expect(hash).to eq("hello" => {:greeting => 1})
      end
    end
  end

  describe "#add_ngrams_with_suffix" do
    it "adds ngrams to a hash" do
      hash = {}
      text = "some text.text"
      WordTree::Text.add_ngrams_with_suffix(text, hash, 2)
      expect(hash).to eq(
        "some" => 1,
        "text" => 2,
        "some text" => 1,
        "text.text" => 1)
    end

    it "adds suffixes to hash of hashes" do
      hash = {}
      text = "some text.text"
      WordTree::Text.add_ngrams_with_suffix(text, hash, 1, :a)
      WordTree::Text.add_ngrams_with_suffix(text, hash, 2, :b)
      expect(hash).to eq(
        "some" => {:a => 1, :b => 1},
        "text" => {:a => 2, :b => 2},
        "some text" => {:b => 1},
        "text.text" => {:b => 1}
      )
    end
  end
end
