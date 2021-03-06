module WordTree
  module Disk
    # A class that converts from a book ID to a location within the library, e.g.
    #
    # "firstbooknapole00gruagoog"
    #
    #   becomes
    #
    # "fi/og/firstbooknapole00gruagoog/"
    #
    #   or, in context of the full path:
    #
    # [/data/library/] "fi/og/firstbooknapole00gruagoog/" [firstbooknapole00gruagoog.md]
    #
    class LibraryLocator
      # The book ID to locate
      attr_reader :id

      NotPath = Class.new(StandardError)
      
      # Construct a LibraryLocator from a string (book ID)
      def initialize(id)
        @id = id
      end

      def first
        @id[0..1].downcase
      end

      def last
        @id[-2..-1].downcase
      end

      # Returns a "relative" path to be joined to the library root,
      # e.g. if the identifier is "firstbooknapole00gruagoog", then relpath
      # should return "fi/og/firstbooknapole00gruagoog", i.e. probably later to
      # become something like "/data/library/fi/og/firstbooknapole00gruagoog" 
      def relpath
        File.join(first, last, @id)
      end

      # Constructor that is as willing to use a String as it is a LibraryLocator
      def self.identity(id)
        id.is_a?(LibraryLocator) ? id : new(id)
      end

      def self.id_from_path(path)
        raise NotPath, "not a path" if path.nil? or !path.is_a?(String)
        File.basename(path).sub(/\.[^\.]+$/, '')
      end
    end
  end
end