module WordTree
  # A class that converts from a book ID to a location within the library
  class LibraryLocator
    # The book ID to locate
    attr_reader :id

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
  end
end