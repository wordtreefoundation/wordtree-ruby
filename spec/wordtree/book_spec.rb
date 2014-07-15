require 'spec_helper'
require 'wordtree/book'
require 'tempfile'

describe WordTree::Book do
  it "initializes" do
    expect{ WordTree::Book.new("library") }.to_not raise_error
  end

  it "file_id defaults to archive_org_id" do
    book = WordTree::Book.new("library", :archive_org_id => "abc")
    expect(book.file_id).to eq("abc")
  end

  context "with library" do
    let(:library) { double("library") }
    let(:book) { WordTree::Book.new(library, :file_id => "abc") }

    it "has filepath" do
      expect(library).to receive("path_for_file").with("abc").and_return("/tmp/ab/bc/abc")
      expect(book.filepath).to eq("/tmp/ab/bc/abc/abc.md")
    end

    it "loads from disk (yaml, content)" do
      book.load_from_disk(fixture("book.md"))
      expect(book.file_id).to eq("abcxyz")
      expect(book.year).to eq(1800)
      expect(book.content).to eq("Book with content")
    end

    it "saves to disk (yaml, content)" do
      book.load_from_disk(fixture("book.md"))

      book.source = "test"
      book.content += "."

      tmp = Tempfile.new('wordtree').path
      book.save_to_disk(tmp)

      updated = Preambular.load(tmp)
      expect(updated.metadata).to eq({:file_id => "abcxyz", :year => 1800, :source => "test"})
      expect(updated.content).to eq("Book with content.")
    end
  end
end