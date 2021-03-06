require_relative '../../spec_helper'
require 'tmpdir'
require 'preamble'
require 'wordtree/disk/librarian'

describe WordTree::Disk::Librarian do
  let(:root) { Dir.mktmpdir }
  let(:library) { WordTree::Disk::Library.new(root) }
  let(:librarian) { WordTree::Disk::Librarian.new(library) }

  it "downloads an archive.org book" do
    VCR.use_cassette('archive_org_download_book') do
      librarian.archive_org_get("firstbooknapole00gruagoog")
      book = librarian.find("firstbooknapole00gruagoog")
      expect(book.year).to eq(1809)
    end
  end

  context "with fixture library" do
    # Need a read-only library with fixtures in it for some tests
    let(:root) { fixture("library") }

    describe "#find" do
      it "returns nil if the book is not found" do
        book = librarian.find("nobook")
        expect(book).to be_nil
      end

      it "loads book from disk" do
        book = librarian.find("book")
        expect(book.id).to eq("book")
        expect(book.year).to eq(1800)
        expect(book.content).to eq("Book with content")
      end
    end

    describe "#each" do
      it "iterates through each book" do
        book_sizes = librarian.map{ |book| book.size_bytes }
        expect(book_sizes).to contain_exactly(17, 23)
      end
    end
  end
end