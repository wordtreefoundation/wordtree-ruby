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

    it "loads book from disk" do
      book = librarian.find("book")
      expect(book.id).to eq("book")
      expect(book.year).to eq(1800)
      expect(book.content).to eq("Book with content")
    end

    it "saves to disk (yaml, content)" do
      tmp_root = Dir.mktmpdir
      tmp_library = WordTree::Disk::Library.new(tmp_root)
      tmp_librarian = WordTree::Disk::Librarian.new(tmp_library)

      book = librarian.find("book")

      book.source = "test"
      book.content += "."

      tmp_librarian.save(book)

      updated = Preamble.load(tmp_library.path_to("book"))
      expect(updated.metadata).to eq(
        :id => "book",
        :year => 1800,
        :source => "test",
        :simhash => 14921967289891934128,
        :size_bytes => 17)
      expect(updated.content).to eq("Book with content.")
    end

  end
end