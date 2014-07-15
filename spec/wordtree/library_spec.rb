require 'spec_helper'
require 'wordtree/library'

describe WordTree::Library do
  let(:library) { WordTree::Library.new(:path => "/tmp/library") }

  it "initializes with path" do
    expect(library.path).to eq("/tmp/library")
  end

  it "gets path_for_file_id" do
    expect(library.path_for_file_id("abcd")).to eq("/tmp/library/ab/cd/abcd")
  end

  it "mkdir makes the directory on disk" do
    expect(File.exist?(library.path)).to be_falsy
    library.mkdir
    expect(File.exist?(library.path)).to be_truthy
  end
end
