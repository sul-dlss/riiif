require 'spec_helper'

RSpec.describe Riiif::ImagemagickCommandFactory do
  let(:path) { 'foo.tiff' }

  describe '.build' do
    subject { described_class.build(path, transformation) }

    let(:transformation) do
      Riiif::Transformation.new('region',
                                'size',
                                'quality',
                                'rotation',
                                format)
    end

    context "when it's a jpeg" do
      let(:format) { 'jpg' }
      it { is_expected.to match(/-quality 85/) }
    end

    context "when it's a tiff" do
      let(:format) { 'tif' }
      it { is_expected.not_to match(/-quality/) }
    end
  end
end
