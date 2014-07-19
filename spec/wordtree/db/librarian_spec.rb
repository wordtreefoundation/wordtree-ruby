require_relative '../../spec_helper'
require 'tmpdir'
require 'preamble'
require 'wordtree/db/librarian'

describe WordTree::DB::Librarian do
  it "instantiates" do
    WordTree::DB::Librarian.new("connection")
  end

  context "with rethinkdb connection" do
    let(:r) { RethinkDB::RQL.new }
    let(:rdb) { r.connect(
      :host => RDB_CONFIG[:host],
      :port => RDB_CONFIG[:port],
      :db   => RDB_CONFIG[:db]
    ) }

    let(:librarian) { WordTree::DB::Librarian.new(rdb) }

    before(:each) do
      begin
        r.table_drop('books').run(rdb)
      rescue RethinkDB::RqlRuntimeError
      ensure
        r.table_create('books').run(rdb)
      end
    end

    describe "#find" do
      it "returns nil if book doesn't exist" do
        book = librarian.find("abc")
        expect(book).to be_nil
      end

      it "finds a book" do
        r.table('books').insert(
          :id => "firstbooknapole00gruagoog",
          :year => 1809).run(rdb)
        book = librarian.find("firstbooknapole00gruagoog")
        expect(book).to be_a(WordTree::Book)
      end
    end

    describe "#save" do
      it "saves a book to the db" do
        book = WordTree::Book.create('test', {:year => 1800}, "body")
        librarian.save(book)
        result = r.table('books').run(rdb).to_a
        expect(result).to eq([{
          "id" => "test",
          "simhash" => 1318950168412674304,
          "size_bytes" => 4,
          "year" => 1800}])
      end
    end
  end
end