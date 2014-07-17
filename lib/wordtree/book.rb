require 'virtus'

module WordTree
  class Book
    include Virtus.model

    attribute :id, String, :default => :default_id
    attribute :archive_org_id, String
    attribute :title, String
    attribute :author, String
    attribute :year, Integer
    attribute :source, String
    attribute :status, String
    attribute :size_bytes, Integer

    attribute :content, String

    def self.create(id, metadata, content)
      new(metadata.merge("id" => id, "content" => content))
    end

    def default_id
      archive_org_id
    end

    def metadata
      attributes.select{ |k,v| !v.nil? && k != :content }
    end
  end
end