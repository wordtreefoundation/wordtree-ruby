require 'preamble'
require 'wordtree/book'
require 'wordtree/library'
require 'wordtree/archdown'

module WordTree
  class Librarian
    attr_reader :library

    def initialize(library)
      @library = library
    end

    def find(book_id)
      retrieved = Preamble.load(library.path_to(book_id))
      Book.create(book_id, retrieved.metadata, retrieved.content)
    end

    def save(book)
      library.mkdir(book.id)
      Preamble.new(book.metadata, book.content).save(library.path_to(book.id))
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