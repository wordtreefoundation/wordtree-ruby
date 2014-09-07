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

      it "loads ngrams if available" do
        book = librarian.find("book")
        expect(book).to_not receive(:count_ngrams)
        expect(book.ngrams(1)).to eq("xyz" => 1)
      end
    end

    describe "#each" do
      it "iterates through each book" do
        book_sizes = librarian.map{ |book| book.size_bytes }
        expect(book_sizes).to contain_exactly(17, 23)
      end
    end

    it "saves ngrams to disk" do
      tmp_root = Dir.mktmpdir
      tmp_library = WordTree::Disk::Library.new(tmp_root)
      tmp_librarian = WordTree::Disk::Librarian.new(tmp_library)

      book = librarian.find("book")
      book.ngrams(1)
      book.ngrams(2)

      tmp_librarian.save(book)

      ngrams_filepath = tmp_library.path_to("book", :ngrams, :n => 1)
      expect(File.exist?(ngrams_filepath)).to be_truthy
    end

    it "saves to disk (yaml, content)" do
      tmp_root = Dir.mktmpdir
      tmp_library = WordTree::Disk::Library.new(tmp_root)
      tmp_librarian = WordTree::Disk::Librarian.new(tmp_library)

      book = librarian.find_without_ngrams("book")

      book.source = "test"
      book.content += "."

      tmp_librarian.save(book)

      updated = Preamble.load(tmp_library.path_to("book"))
      expect(updated.metadata).to eq(
        :id => "book",
        :archive_org_id => "book",
        :year => 1800,
        :source => "test",
        :size_bytes => 17)
      expect(updated.content).to eq("Book with content.")
    end

  end
end