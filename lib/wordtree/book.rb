require 'virtus'
require 'wordtree/text_utils'

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
    # Size of the content in bytes
    attribute :size_bytes, Integer
    # A simhash (locality-sensitive hash) of the content
    attribute :simhash, String

    attribute :content, String

    def self.create(id, metadata, content)
      new(metadata.merge("id" => id, "content" => content))
    end

    def default_id
      archive_org_id
    end

    def metadata
      attributes.select{ |k,v| !v.nil? && k != :content && k != :id }
    end

    def clean_content
      TextUtils.clean_text(content)
    end
  end
end