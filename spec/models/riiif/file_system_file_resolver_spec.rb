require 'spec_helper'

describe Riiif::FileSystemFileResolver do
  let(:resolver) { described_class.new }

  describe '#find' do
    subject { resolver.find(id) }

    context "when the file isn't found" do
      let(:id) { '1234' }
      it 'raises an error' do
        expect { subject }.to raise_error Riiif::ImageNotFoundError
      end
    end

    context 'when a jpeg2000 file is found' do
      let(:id) { 'world' }
      it 'returns the jpeg2000 file' do
        expect(subject.path).to eq resolver.root + '/spec/samples/world.jp2'
      end
    end
  end

  describe '#input_types' do
    subject { described_class.new.send(:input_types) }

    it 'includes jp2 extension' do
      expect(subject).to include 'jp2'
    end

    it 'includes jpg extension' do
      expect(subject).to include 'jpg'
    end

    it 'includes tif extension' do
      expect(subject).to include 'tif'
    end

    it 'includes tiff extension' do
      expect(subject).to include 'tiff'
    end

    it 'includes png extension' do
      expect(subject).to include 'png'
    end
  end

  describe '#pattern' do
    subject { resolver.pattern(id) }

    context 'with dashes' do
      let(:id) { 'foo-bar-baz' }
      it 'accepts ids with dashes' do
        expect { subject }.not_to raise_error
      end
    end

    context 'with colons' do
      let(:id) { 'fo:baz' }
      it 'accepts ids with colons' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
