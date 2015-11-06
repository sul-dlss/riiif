require 'spec_helper'

describe Riiif::Image do
  before { Rails.cache.clear }
  let(:filename) { File.expand_path('spec/samples/world.jp2') }
  subject { Riiif::Image.new('world') }
  describe "happy path" do
    before do
      expect(subject.image).to receive(:execute).with("convert #{filename} jpg:-").and_return('imagedata')
    end
    it "should render" do
      expect(subject.render('size' => 'full', format: 'jpg')).to eq 'imagedata'
    end
  end

  it "should be able to override the file used for the Image" do
    img = Riiif::Image.new('some_id', Riiif::File.new(filename))
    expect(img.id).to eq 'some_id'
    expect(img.info).to eq height: 400, width: 800
  end

  describe "without a format" do
    it "should raise an error" do
      expect { subject.render('size' => 'full') }.to raise_error ArgumentError
    end
  end

  describe "info" do
    it "should return the data" do
      expect(subject.info).to eq height: 400, width:800
    end
  end

  context "using HTTPFileResolver" do
    before do
      Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new
      Riiif::Image.file_resolver.id_to_uri = lambda do |id|
        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
      end
    end
    after do
      Riiif::Image.file_resolver = Riiif::FileSystemFileResolver.new
    end

    describe "get info" do
      subject { Riiif::Image.new('Cave_26,_Ajanta') }
      it "should be easy" do
        expect(subject.info).to eq height: 390, width:600
      end
    end

    context "when the rendered image is in the cache" do
      subject { Riiif::Image.new('Cave_26,_Ajanta') }
      before { allow(Rails.cache).to receive(:fetch).and_return('expected') }

      it "should not fetch the file" do
        expect(Riiif::Image.file_resolver).not_to receive(:find)
        expect(subject.render(region: 'full', format: 'png')).to eq 'expected'
      end
    end
  end

  describe "mogrify" do
    describe "region" do
      it "should return the original when specifing full size" do
        expect(subject.image).to receive(:execute).with("convert #{filename} png:-")
        subject.render(region: 'full', format: 'png')
      end
      it "should handle absolute geometry" do
        expect(subject.image).to receive(:execute).with("convert -crop 60x75+80+15 #{filename} png:-")
        subject.render(region: '80,15,60,75', format: 'png')
      end
      it "should handle percent geometry" do
        expect(subject.image).to receive(:execute).with("identify -format %hx%w #{filename}").and_return('131x175')
        expect(subject.image).to receive(:execute).with("convert -crop 80%x70+18+13 #{filename} png:-")
        subject.render(region: 'pct:10,10,80,70', format: 'png')
      end
      it "should raise an error for invalid geometry" do
        expect { subject.render(region: '150x75', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end

    describe "resize" do
      it "should return the original when specifing full size" do
        expect(subject.image).to receive(:execute).with("convert #{filename} png:-")
        subject.render(size: 'full', format: 'png')
      end
      it "should handle integer percent sizes" do
        expect(subject.image).to receive(:execute).with("convert -resize 50% #{filename} png:-")
        subject.render(size: 'pct:50', format: 'png')
      end
      it "should handle float percent sizes" do
        expect(subject.image).to receive(:execute).with("convert -resize 12.5% #{filename} png:-")
        subject.render(size: 'pct:12.5', format: 'png')
      end
      it "should handle w," do
        expect(subject.image).to receive(:execute).with("convert -resize 50 #{filename} png:-")
        subject.render(size: '50,', format: 'png')
      end
      it "should handle ,h" do
        expect(subject.image).to receive(:execute).with("convert -resize x50 #{filename} png:-")
        subject.render(size: ',50', format: 'png')
      end
      it "should handle w,h" do
        expect(subject.image).to receive(:execute).with("convert -resize 150x75! #{filename} png:-")
        subject.render(size: '150,75', format: 'png')
      end
      it "should handle bestfit (!w,h)" do
        expect(subject.image).to receive(:execute).with("convert -resize 150x75 #{filename} png:-")
        subject.render(size: '!150,75', format: 'png')
      end
      it "should raise an error for invalid size" do
        expect { subject.render(size: '150x75', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end

    describe "rotate" do
      it "should return the original when specifing full size" do
        expect(subject.image).to receive(:execute).with("convert #{filename} png:-")
        subject.render(rotation: '0', format: 'png')
      end
      it "should handle floats" do
        expect(subject.image).to receive(:execute).with("convert -virtual-pixel white +distort srt 22.5 #{filename} png:-")
        subject.render(rotation: '22.5', format: 'png')
      end
      it "should raise an error for invalid angle" do
        expect { subject.render(rotation: '150x', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end

    describe "quality" do
      it "returns the original when specifing default" do
        expect(subject.image).to receive(:execute).with("convert #{filename} png:-")
        subject.render(quality: 'default', format: 'png')
      end
      it "should return the original when specifing color" do
        expect(subject.image).to receive(:execute).with("convert #{filename} png:-")
        subject.render(quality: 'color', format: 'png')
      end
      it "should convert to grayscale" do
        expect(subject.image).to receive(:execute).with("convert -colorspace Gray #{filename} png:-")
        subject.render(quality: 'grey', format: 'png')
      end
      it "should convert to bitonal" do
        expect(subject.image).to receive(:execute).with("convert -colorspace Gray -type Bilevel #{filename} png:-")
        subject.render(quality: 'bitonal', format: 'png')
      end
      it "should raise an error for invalid angle" do
        expect { subject.render(rotation: '150x', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end
  end
end
