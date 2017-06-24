require 'spec_helper'

RSpec.describe Riiif::ImageInformation do
  describe '#valid?' do
    subject { info.valid? }

    context 'with valid dimensions' do
      let(:info) { described_class.new(100, 200) }

      it { is_expected.to be true }
    end

    context 'with nil dimensions' do
      let(:info) { described_class.new(nil, nil) }

      it { is_expected.to be false }
    end
  end
end
