require 'fileutils'
require 'find'

require 'wordtree/archdown'
require 'wordtree/disk/library_locator'

module WordTree
  module Disk
    class Library
      include Enumerable

      FILE_TYPES = {
        :raw => "%{id}.md",
        :ngrams => "%{id}.%{n}grams.json"
      }

      # The file path to the root of the library directory, e.g. /data/library
      attr_reader :root

      def initialize(root)
        @root = root
      end

      # returns the full path of a book's subdirectory within the library
      # Accepts either a String or a LibraryLocator object
      def dir_of(book_id)
        File.expand_path(LibraryLocator.identity(book_id).relpath, root)
      end

      def path_to(book_id, type=:raw, opts={})
        File.join(dir_of(book_id), file_type(book_id, type, opts))
      end

      def file_type(book_id, type=:raw, opts={})
        locator = LibraryLocator.identity(book_id)
        template = FILE_TYPES[type]
        raise ArgumentError, "unable to find file type template #{type.inspect}" if template.nil?
        template % {:id => locator.id}.merge(opts)
      end

      # Create all subdirs up to the location where a book is stored
      # Accepts either a String or a LibraryLocator object
      def mkdir(book_id)
        FileUtils.mkdir_p(dir_of(book_id))
      end

      # Breadth-first search of the directory structure, operating on each book
      def each(file_suffix_re=/\.(md|txt)$/, &block)
        Find.find(@root) do |path|
          if FileTest.directory?(path)
            if File.basename(path)[0] == ?.
              # Don't look any further into this directory.
              Find.prune
            else
              next
            end
          elsif path =~ file_suffix_re
            yield path, LibraryLocator.id_from_path(path)
          end
        end
      end

    end
  end
end