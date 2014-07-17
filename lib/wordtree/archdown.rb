require 'archivist/client'
require 'retriable'

module WordTree
  class Archdown
    attr_reader :client

    def initialize
      @client = Archivist::Client::Base.new
    end

    def metadata_for(archivist_book)
      {
        'id'             => book.identifier,
        'title'          => book.title,
        'author'         => book.creators ? book.creators.join('; ') : nil,
        'year'           => book.date.year,
        'source'         => "http://archive.org/details/#{book.identifier}",
        'status'         => "OCR ONLY",
        'archive_org_id' => book.identifier,
      }
    end

    def content_for(archivist_book)
      [archivist_book.download, nil]
    rescue Archivist::Model::Document::UnsupportedFormat => e
      [nil, e.to_s]
    rescue StandardError => e
      [nil, e.to_s]
    end

    def download_all(search_terms, &each_book)
      page = 1
      loop do
        archivist_books =
          ::Retriable.retriable(:on => Faraday::Error::TimeoutError) do
            @client.search(search_terms.merge(:page => page))
          end
  
        break if archivist_books.empty?
  
        archivist_books.each do |archivist_book|
          download(archivist_book, &each_book)
        end

        page += 1
      end
    end

    def download(archivist_book, &block)
      metadata = metadata_for(archivist_book)
      content, failure = content_for(archivist_book)

      yield metadata, content, failure if block_given?
    end

  end
end