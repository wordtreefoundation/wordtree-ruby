require 'virtus'
require 'simhash'

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
    attribute :size_bytes, Integer, :default => :content_size
    # A simhash (locality-sensitive hash) of the content
    attribute :simhash, Integer, :default => :calculate_simhash

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

    def content_clean
      TextUtils.clean_text(content)
    end

    def content_size
      content ? content.size : nil
    end

    def calculate_simhash
      content ? content_clean.simhash(:split_by => /\s/) : nil
    end
  end
end