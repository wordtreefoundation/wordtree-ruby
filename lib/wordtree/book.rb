require 'virtus'
require 'preambular'

module WordTree
  class Book
    include Virtus.model

    attr_accessor :content

    attribute :file_id, String, :default => :default_file_id
    attribute :archive_org_id, String
    attribute :title, String
    attribute :author, String
    attribute :year, Integer
    attribute :source, String
    attribute :status, String
    attribute :size_bytes, Integer

    def initialize(library, attrs={})
      @library = library
      @content = nil
      super(attrs)
    end

    def default_file_id
      archive_org_id
    end

    # Directory where file can be found
    def path
      @library.path_for_file(file_id)
    end

    # Name of the file
    def file
      "#{file_id}.md"
    end

    # Full path to the file
    def filepath
      File.expand_path(file, path)
    end

    def non_nil_attributes
      attributes.select{ |k,v| !v.nil? }
    end

    def load_from_disk(fp = filepath)
      self.tap do
        Preambular.load(fp).tap do |book|
          self.attributes = book.metadata
          self.content = book.content
        end
      end
    end

    def save_to_disk(fp = filepath)
      self.tap do
        Preambular.new(non_nil_attributes, content).save(fp)
      end
    end
  end
end