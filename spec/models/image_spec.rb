require 'spec_helper'

describe Riiif::Image do
  subject { Riiif::Image.new('world') }
  describe "without a format" do
    it "should raise an error" do
      expect { subject.render('size' => 'full') }.to raise_error ArgumentError
    end
  end
  describe "resize" do
    it "should return the original when specifing full size" do
      new_img = subject.render(size: 'full', format: 'png')
      new_img.should be_kind_of String
    end
  end
end
