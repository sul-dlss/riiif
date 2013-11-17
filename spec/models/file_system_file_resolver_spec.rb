require 'spec_helper'

describe Riiif::FileSystemFileResolver do
  subject { Riiif::FileSystemFileResolver }
  it "should get nil when the file isn't found" do
    expect(subject.find('1234')).to be_nil
  end
  it "should get the jpeg2000 file" do
    expect(subject.find('world')).to eq Riiif::FileSystemFileResolver.root + '/spec/samples/world.jp2'
  end

  it "should accept ids with dashes" do
    subject.pattern('foo-bar-baz')
  end
end
