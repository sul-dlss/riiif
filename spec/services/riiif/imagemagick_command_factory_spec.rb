require 'spec_helper'

RSpec.describe Riiif::ImagemagickCommandFactory do
  let(:path) { 'foo.tiff' }
  let(:info) { double(height: 100, width: 100, format: 'JPEG') }

  describe '.command' do
    subject { instance.command }
    let(:instance) { described_class.new(path, info, transformation) }

    let(:transformation) do
      IIIF::Image::Transformation.new(region: IIIF::Image::Region::Full.new,
                                      size: IIIF::Image::Size::Full.new,
                                      quality: 'quality',
                                      rotation: 15.2,
                                      format: format)
    end

    context "when it's a jpeg" do
      let(:format) { 'jpg' }
      it { is_expected.to match(/-quality 85/) }
    end

    context "when it's a tiff" do
      let(:format) { 'tif' }
      it { is_expected.not_to match(/-quality/) }
    end

    describe '#external_command' do
      let(:format) { 'jpg' }
      around do |example|
        orig = described_class.external_command
        described_class.external_command = 'gm convert'

        example.run

        described_class.external_command = orig
      end

      it { is_expected.to match(/\Agm convert/) }
    end
  end
end
