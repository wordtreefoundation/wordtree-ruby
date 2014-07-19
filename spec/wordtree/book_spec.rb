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
    book = WordTree::Book.create("book", {}, "Wi&ld\nContent!")
    expect(book.content_clean).to eq("wild content\n")
  end
end