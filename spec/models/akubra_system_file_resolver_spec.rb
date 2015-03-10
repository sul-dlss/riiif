require 'spec_helper'

describe Riiif::AkubraSystemFileResolver do
  subject { Riiif::AkubraSystemFileResolver.new(Rails.root.join('../../spec/samples/'),'jp2',[[0,2],[2,2],[4,1]]) }
  it "should raise an error when the file isn't found" do
    expect{subject.find('demo:2')}.to raise_error Riiif::ImageNotFoundError
  end

  it "should get the jpeg2000 file" do
    expect(subject.find('demo:1').path).to eq Riiif::File.new(Dir.glob(subject.pathroot + '22/7e/9/info%3Afedora%2Fdemo%3A1%2Fjp2%2Fjp2.0').first).path
  end

end
