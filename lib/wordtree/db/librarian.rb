require 'rethinkdb'
require 'wordtree/book'

module WordTree
  module DB
    class Librarian
      def initialize(rethinkdb_connection)
        @rdb = rethinkdb_connection
        @r = RethinkDB::RQL.new
      end

      def find(book_id)
        result = @r.table('books').get(book_id).run(@rdb)
        result ? Book.new(result) : nil
      end

      def save(book)
        result = @r.table('books').insert(book.metadata, :upsert => true).run(@rdb)
        return result["replaced"] == 1
      end
    end
  end
end