require_relative '../spec_helper'
require 'tmpdir'
require 'preamble'
require 'wordtree/librarian'

describe WordTree::Librarian do
  let(:root) { Dir.mktmpdir }
  let(:library) { WordTree::Library.new(root) }
  let(:librarian) { WordTree::Librarian.new(library) }

  context "with fixture library" do
    let(:root) { fixture("library") }

    it "loads book from disk" do
      book = librarian.find("book")
      expect(book.id).to eq("book")
      expect(book.year).to eq(1800)
      expect(book.content).to eq("Book with content")
    end

    it "saves to disk (yaml, content)" do
      tmp_root = Dir.mktmpdir
      tmp_library = WordTree::Library.new(tmp_root)
      tmp_librarian = WordTree::Librarian.new(tmp_library)

      book = librarian.find("book")

      book.source = "test"
      book.content += "."

      tmp_librarian.save(book)

      updated = Preamble.load(tmp_library.path_to("book"))
      expect(updated.metadata).to eq({:id => "book", :year => 1800, :source => "test"})
      expect(updated.content).to eq("Book with content.")
    end

  end
end