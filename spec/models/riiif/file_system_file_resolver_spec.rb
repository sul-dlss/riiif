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

    context 'when the file is found' do
      let(:id) { 'world' }
      it 'returns the jpeg2000 file' do
        expect(subject.path).to eq resolver.root + '/spec/samples/world.jp2'
      end
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

    context 'with colins' do
      let(:id) { 'fo:baz' }
      it 'accepts ids with colins' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
