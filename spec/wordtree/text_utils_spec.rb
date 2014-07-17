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
    let(:sample_text) { "This, [here]  is awesome, right?" }
    it "wraps" do
      cleaned = WordTree::TextUtils.clean_text(sample_text, 10)
      expect(cleaned).to eq("this here\nis awesome\nright\n")

      cleaned = WordTree::TextUtils.clean_text(sample_text, 15)
      expect(cleaned).to eq("this here is\nawesome right\n")

      cleaned = WordTree::TextUtils.clean_text(sample_text, 150)
      expect(cleaned).to eq("this here is awesome right\n")
    end

    let(:sample_dash) { "What-\never\ndo you\n mean?"}
    it "joins lines ending in -" do
      cleaned = WordTree::TextUtils.clean_text(sample_dash, 10)
      expect(cleaned).to eq("whatever\ndo you\nmean\n")
    end
  end
end
