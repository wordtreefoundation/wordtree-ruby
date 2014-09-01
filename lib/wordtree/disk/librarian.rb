require 'preamble'
require 'wordtree/book'
require 'wordtree/disk/library'
require 'wordtree/archdown'

module WordTree
  module Disk
    class Librarian
      include Enumerable

      attr_reader :library

      # @library can be either a string (the path of the library) or a
      # WordTree::Disk::Library object
      def initialize(library)
        if library.is_a? String
          @library = WordTree::Disk::Library.new(library)
        else
          @library = library
        end
      end

      def find(book_id)
        begin
          retrieved = Preamble.load(library.path_to(book_id), :external_encoding => "utf-8")
          Book.create(book_id, retrieved.metadata, retrieved.content)
        rescue Errno::ENOENT
          nil
        end
      end

      def each(file_suffix_re=/\.(md|txt)$/, &block)
        library.each(file_suffix_re) do |path|
          retrieved = Preamble.load(path, :external_encoding => "utf-8")
          yield Book.new(retrieved.metadata.merge("content" => retrieved.content))
        end
      end

      def save(book)
        library.mkdir(book.id)
        Preamble.new(book.metadata, book.content || "").save(library.path_to(book.id))
      end

      def archive_org_get(*book_ids, &block)
        book_ids.map do |book_id|
          archive_org_get_with_conditions(identifier: book_id, &block)
        end.flatten(1)
      end

      def archive_org_get_range_of_years(start_year, end_year, &block)
        archive_org_get_with_conditions({
          :start_year => start_year,
          :end_year   => end_year
        }, &block)
      end

      # Downloads a set of books to the on-disk library and
      # returns a list of book_ids
      def archive_org_get_with_conditions(conditions, &block)
        archdown = Archdown.new
        [].tap do |archive_org_ids|
          archdown.download_all(conditions) do |metadata, content, failure|
            if failure
              #TODO: logging
              $stderr.puts "Unable to download from archive.org: #{failure}"
            else
              book = Book.create(metadata["archive_org_id"], metadata, content)
              save(book)
              yield book, self if block_given?
              archive_org_ids << book.id
            end
          end
        end
      end
    end
  end
end