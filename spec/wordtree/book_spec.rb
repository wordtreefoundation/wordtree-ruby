require 'spec_helper'
require 'wordtree/book'
require 'tempfile'

describe WordTree::Book do
  it "initializes" do
    expect{ WordTree::Book.new }.to_not raise_error
  end

  it "file_id defaults to archive_org_id" do
    book = WordTree::Book.new(:archive_org_id => "abc")
    expect(book.id).to eq("abc")
  end

  it "can return cleaned content" do
    content = "Wi&ld\nContent!"
    book = WordTree::Book.create("book", {}, content)
    expect(content).to eq("Wi&ld\nContent!")
    expect(book.content_clean).to eq("wild content.")
  end

  # context "ngrams" do
  #   let(:content) { "A man. A plan. And a man."}
  #   let(:book) { WordTree::Book.create("book", {}, content) }
  #   let(:one_grams) { { "a" => 3, "man" => 2, "plan" => 1, "and" => 1, "." => 3 } }
  #   let(:two_grams) {
  #     {"a man" => 2, "man ." => 2, ". a" => 1, "a plan" => 1,
  #      "plan ." => 1, ". and" => 1, "and a" => 1}
  #   }
  #   describe "#ngrams" do
  #     it "creates a hash lookup table" do
  #       hash = book.count_ngrams(1)
  #       expect(hash).to be_a(Hash)
  #     end

  #     it "has counts of ngrams" do
  #       hash = book.count_ngrams(1)
  #       expect(hash).to eq(one_grams)
  #       hash = book.count_ngrams(2)
  #       expect(hash).to eq(two_grams)
  #     end
  #   end
  # end
end