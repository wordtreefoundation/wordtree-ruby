require 'spec_helper'
require 'wordtree/disk/library'
require 'tmpdir'

describe WordTree::Disk::LibraryLocator do
  describe "#id_from_path" do
    it "disallows non-strings" do
      expect{ WordTree::Disk::LibraryLocator.id_from_path(:test) }.to raise_error
    end

    it "removes the directory" do
      id = WordTree::Disk::LibraryLocator.id_from_path("/path/to/book.txt")
      expect(id).to eq "book"
    end

    it "removes the suffix" do
      id = WordTree::Disk::LibraryLocator.id_from_path("/path/to/book.txt.md")
      expect(id).to eq "book.txt"
    end
  end
end