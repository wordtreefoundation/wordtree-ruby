require 'spec_helper'
require 'wordtree/disk/library'
require 'tmpdir'

describe WordTree::Disk::Library do
  let(:root) { Dir.mktmpdir('library') }
  let(:library) { WordTree::Disk::Library.new(root) }

  it "initializes with path" do
    expect(library.root).to eq(root)
  end

  it "gets dir_of a book_id" do
    expect(library.dir_of("abcd")).to eq(File.join(root, "/ab/cd/abcd"))
  end

  it "mkdir makes a directory on disk" do
    book_id = 'xyz'
    expect(File.exist?(library.dir_of(book_id))).to be_falsy
    library.mkdir(book_id)
    expect(File.exist?(library.dir_of(book_id))).to be_truthy
  end

  context "with fixture library" do
    let(:root) { fixture('library') }

    describe "#each" do
      it "iterates through each book" do
        books = library.map.to_a
        expect(books.size).to eq 2
      end
    end
  end

  describe "#file_type" do
    it "interpolates n" do
      expect(library.file_type("abc", :ngrams, :n => 1)).to eq("abc.1grams.json")
    end
  end
end
