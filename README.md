# Wordtree

This is the WordTree ruby gem for text analysis.

## Installation

    $ gem install wordtree

## Usage

    require 'wordtree'

    library = WordTree::Library.new("/tmp/library")
    librarian = WordTree::Librarian.new(library)

Download a book from Archive.org to your "library":

    book_ids = librarian.archive_org_get(
      'latewarbetween_00hunt',
      'firstbooknapole00gruagoog')

Find a book in your on-disk "library":

    book = librarian.find('firstbooknapole00gruagoog')
    book.metadata
    book.content

Modify and save a book to your "library":

    book.year = 2014
    librarian.save(book)



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
