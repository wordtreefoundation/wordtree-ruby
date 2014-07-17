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
end