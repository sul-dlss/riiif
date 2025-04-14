RSpec.describe Riiif::File do
  describe '#info_extractor_class' do
    subject { described_class.info_extractor_class }

    context 'when not using vips' do
      it { is_expected.to eq Riiif::ImageMagickInfoExtractor }
    end

    context 'when vips is configured' do
      before { allow(Riiif).to receive(:use_vips?).and_return true }

      it { is_expected.to eq Riiif::VipsInfoExtractor }
    end
  end
end
