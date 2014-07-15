require 'virtus'
require 'fileutils'
require 'archdown'

module WordTree
  class Library
    include Virtus.model

    attribute :path

    # A file_id is a string that uniquely identifies a resource in the library.
    # For instance, if the book comes from archive.org, it is the archive.org
    # unique ID (e.g. "firstbooknapole00gruagoog").
    def path_for_file_id(file_id)
      File.join(path, file_id[0..1], file_id[-2..-1], file_id)
    end

    def mkdir
      FileUtils.mkdir_p(path)
    end

    def archive_org_download_book(file_id, &block)
      archive_org_download({
        :filters => ["identifier:firstbooknapole00gruagoog"]
      }, &block)
    end

    def archive_org_download_range(start_year, end_year, &block)
      archive_org_download({
        :start_year => start_year,
        :end_year   => end_year
      }, &block)
    end

    def archive_org_download(conditions, &block)
      download = Archdown::Download.new(path, conditions)
      [].tap do |archive_org_ids|
        download.go! do |metadata, librarian|
          block.call(metadata, librarian)
          archive_org_ids << metadata["archive_org_id"]
        end
      end
    end
  end
end