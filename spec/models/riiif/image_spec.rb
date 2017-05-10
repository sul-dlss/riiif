require 'spec_helper'

RSpec.describe Riiif::Image do
  before { Riiif::Image.cache.clear }
  let(:filename) { File.expand_path('spec/samples/world.jp2') }
  subject { described_class.new('world') }
  describe 'happy path' do
    before do
      expect(subject.image).to receive(:execute)
        .with("convert -quality 85 -sampling-factor 4:2:0 -strip #{filename} jpg:-")
        .and_return('imagedata')
    end
    it 'renders' do
      expect(subject.render('size' => 'full', format: 'jpg')).to eq 'imagedata'
    end
  end

  it 'is able to override the file used for the Image' do
    img = described_class.new('some_id', Riiif::File.new(filename))
    expect(img.id).to eq 'some_id'
    expect(img.info).to eq Riiif::ImageInformation.new(800, 400)
  end

  describe 'without a format' do
    it 'raises an error' do
      expect { subject.render('size' => 'full') }.to raise_error ArgumentError
    end
  end

  describe 'info' do
    it 'returns the data' do
      expect(subject.info).to eq Riiif::ImageInformation.new(800, 400)
    end
  end

  context 'using HTTPFileResolver' do
    before do
      described_class.file_resolver = Riiif::HTTPFileResolver.new
      described_class.file_resolver.id_to_uri = lambda do |id|
        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/#{id}.jpg/600px-#{id}.jpg"
      end
    end
    after do
      described_class.file_resolver = Riiif::FileSystemFileResolver.new
    end

    describe 'get info' do
      subject { described_class.new('Cave_26,_Ajanta') }
      it 'is easy' do
        expect(subject.info).to eq Riiif::ImageInformation.new(600, 390)
      end
    end

    context 'when the rendered image is in the cache' do
      subject { described_class.new('Cave_26,_Ajanta') }
      before { allow(Riiif::Image.cache).to receive(:fetch).and_return('expected') }

      it 'does not fetch the file' do
        expect(described_class.file_resolver).not_to receive(:find)
        expect(subject.render(region: 'full', format: 'png')).to eq 'expected'
      end
    end
  end

  describe 'mogrify' do
    describe 'region' do
      it 'returns the original when specifing full size' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -strip #{filename} png:-")
        subject.render(region: 'full', format: 'png')
      end
      it 'handles absolute geometry' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -crop 60x75+80+15 -strip #{filename} png:-")
        subject.render(region: '80,15,60,75', format: 'png')
      end

      it 'handles percent geometry' do
        expect(Riiif::CommandRunner).to receive(:execute)
          .with("identify -format %hx%w #{filename}").and_return('131x175')
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -crop 80%x70+18+13 -strip #{filename} png:-")
        subject.render(region: 'pct:10,10,80,70', format: 'png')
      end

      it 'handles square geometry' do
        expect(Riiif::CommandRunner).to receive(:execute)
          .with("identify -format %hx%w #{filename}").and_return('131x175')
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -crop 131x131+22+0 -strip #{filename} png:-")
        subject.render(region: 'square', format: 'png')
      end
      it 'raises an error for invalid geometry' do
        expect { subject.render(region: '150x75', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end

    describe 'resize' do
      it 'returns the original when specifing full size' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -strip #{filename} png:-")
        subject.render(size: 'full', format: 'png')
      end
      it 'handles integer percent sizes' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -resize 50% -strip #{filename} png:-")
        subject.render(size: 'pct:50', format: 'png')
      end
      it 'handles float percent sizes' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -resize 12.5% -strip #{filename} png:-")
        subject.render(size: 'pct:12.5', format: 'png')
      end
      it 'handles w,' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -resize 50 -strip #{filename} png:-")
        subject.render(size: '50,', format: 'png')
      end
      it 'handles ,h' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -resize x50 -strip #{filename} png:-")
        subject.render(size: ',50', format: 'png')
      end
      it 'handles w,h' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -resize 150x75! -strip #{filename} png:-")
        subject.render(size: '150,75', format: 'png')
      end
      it 'handles bestfit (!w,h)' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -resize 150x75 -strip #{filename} png:-")
        subject.render(size: '!150,75', format: 'png')
      end
      it 'raises an error for invalid size' do
        expect { subject.render(size: '150x75', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end

    describe 'rotate' do
      it 'returns the original when specifing full size' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -strip #{filename} png:-")
        subject.render(rotation: '0', format: 'png')
      end
      it 'handles floats' do
        expect(Riiif::CommandRunner).to receive(:execute)
          .with("convert -virtual-pixel white +distort srt 22.5 -strip #{filename} png:-")
        subject.render(rotation: '22.5', format: 'png')
      end
      it 'raises an error for invalid angle' do
        expect { subject.render(rotation: '150x', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end

    describe 'quality' do
      it 'returns the original when specifing default' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -strip #{filename} png:-")
        subject.render(quality: 'default', format: 'png')
      end
      it 'returns the original when specifing color' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -strip #{filename} png:-")
        subject.render(quality: 'color', format: 'png')
      end
      it 'converts to grayscale' do
        expect(Riiif::CommandRunner).to receive(:execute).with("convert -colorspace Gray -strip #{filename} png:-")
        subject.render(quality: 'grey', format: 'png')
      end
      it 'converts to bitonal' do
        expect(Riiif::CommandRunner).to receive(:execute)
          .with("convert -colorspace Gray -type Bilevel -strip #{filename} png:-")
        subject.render(quality: 'bitonal', format: 'png')
      end
      it 'raises an error for invalid angle' do
        expect { subject.render(rotation: '150x', format: 'png') }.to raise_error Riiif::InvalidAttributeError
      end
    end
  end
end
