require 'rethinkdb'
require 'wordtree/book'

module WordTree
  module DB
    class Librarian
      # @connection can be either a Hash or a RethinkDB::Connection object
      # If a hash, it uses keys :host, :port, and :db
      def initialize(connection)
        @r = RethinkDB::RQL.new
        if connection.is_a? Hash
          @rdb = @r.connect(connection)
        else
          @rdb = connection
        end
      end

      def find(book_id)
        result = @r.table('books').get(book_id).run(@rdb)
        result ? Book.new(result) : nil
      end

      def save(book)
        result = @r.table('books').insert(book.metadata, :upsert => true).run(@rdb)
        return result["replaced"] == 1 || result["inserted"] == 1 || result["unchanged"] == 1
      end

      def search(params, page=1, per_page=20)
        conditions = match_list(params,
                       [:id, :title, :author, :source, :status],
                       [:year, :size_bytes])
        cursor = @r.table('books').
                   order_by(:index => 'year').
                   filter(&conditions).
                   skip((page-1)*per_page).
                   limit(per_page).
                   run(@rdb)
        if !(results = cursor.to_a).empty?
          results.map{ |result| Book.new(result) }
        else
          nil
        end
      end

    protected

      # Create a condition Proc suitable for RethinkDB search queries
      def match_list(params, string_keys=[], numeric_keys=[], escape=true)
        Proc.new do |record|
          (
            string_keys.map do |key|
              if params[key]
                term = escape ? Regexp.escape(params[key]) : params[key]
                record[key.to_s].match("(?i)#{term}")
              end
            end +
            numeric_keys.map do |key|
              if params[key]
                if params[key].include?(',')
                  low, high = params[key].split(',', 2).map{ |v| v.to_i }
                  (record[key.to_s] >= low) & (record[key.to_s] <= high)
                else
                  value = params[key].to_i
                  record[key.to_s].eq(value)
                end
              end
            end
          ).compact.foldl{ |a,b| a & b }
        end
      end

    end
  end
end