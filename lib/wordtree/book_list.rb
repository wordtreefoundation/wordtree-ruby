module WordTree
  class BookList
    include Enumerable

    # can be initialized from the following sources:
    # - a WordTree::Disk::Library object
    # - an open File object (containing a list of files or paths to books)
    # - a String directory (presumed to be the library on disk)
    # - a String file (containing a list of files or paths to books)
    def initialize(source)
      @source = source
      @iterable = iterable_from_source(source)
    end

    def iterable_from_source(source)
      case source
      when WordTree::Disk::Library then
        source
      when File then
        source.read.split("\n").tap do |file|
          file.close
        end
      when String then
        if File.directory?(source)
          WordTree::Disk::Library.new(source)
        elsif File.exist?(source)
          IO.read(source).split("\n")
        else
          raise Errno::ENOENT, "Unable to find source for BookList, #{source.inspect}"
        end
      end
    end

    def each(&block)
      @iterable.each(&block)
    end
  end
end