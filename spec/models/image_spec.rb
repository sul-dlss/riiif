require 'spec_helper'

describe Riiif::Image do
  subject { Riiif::Image.new('world') }
  describe "happy path" do
    let(:inner) { double }
    before do
      expect(inner).to receive(:format).with('jpg')
      expect(inner).to receive(:to_blob).and_return('imagedata')
      subject.stub(:image).and_return(inner)
    end
    it "should render" do
      expect(subject.render('size' => 'full', format: 'jpg')).to eq 'imagedata'
    end
  end

  describe "without a format" do
    it "should raise an error" do
      expect { subject.render('size' => 'full') }.to raise_error ArgumentError
    end
  end

  describe "region" do
    let(:inner) { double(format: true, to_blob: 'imagedata') }
    before do
      subject.stub(:image).and_return(inner)
    end
    it "should return the original when specifing full size" do
      expect(inner).to_not receive(:crop)
      subject.render(region: 'full', format: 'png')
    end
    it "should handle absolute geometry" do
      expect(inner).to receive(:crop).with('60x75+80+15')
      subject.render(region: '80,15,60,75', format: 'png')
    end
    it "should handle percent geometry" do
      expect(inner).to receive(:[]).with(:height).and_return(131)
      expect(inner).to receive(:[]).with(:width).and_return(175)
      expect(inner).to receive(:crop).with('80%x70+18+13')
      subject.render(region: 'pct:10,10,80,70', format: 'png')
    end
    it "should raise an error for invalid geometry" do
      expect { subject.render(region: '150x75', format: 'png') }.to raise_error Riiif::InvalidAttributeError
    end
  end

  describe "resize" do
    let(:inner) { double(format: true, to_blob: 'imagedata') }
    before do
      subject.stub(:image).and_return(inner)
    end
    it "should return the original when specifing full size" do
      expect(inner).to_not receive(:resize)
      subject.render(size: 'full', format: 'png')
    end
    it "should handle percent sizes" do
      expect(inner).to receive(:resize).with('50%')
      subject.render(size: 'pct:50', format: 'png')
    end
    it "should handle w," do
      expect(inner).to receive(:resize).with('50')
      subject.render(size: '50,', format: 'png')
    end
    it "should handle ,h" do
      expect(inner).to receive(:resize).with('x50')
      subject.render(size: ',50', format: 'png')
    end
    it "should handle w,h" do
      expect(inner).to receive(:resize).with('150x75!')
      subject.render(size: '150,75', format: 'png')
    end
    it "should handle bestfit (!w,h)" do
      expect(inner).to receive(:resize).with('150x75')
      subject.render(size: '!150,75', format: 'png')
    end
    it "should raise an error for invalid size" do
      expect { subject.render(size: '150x75', format: 'png') }.to raise_error Riiif::InvalidAttributeError
    end
  end
end
