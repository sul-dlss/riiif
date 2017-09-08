# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Riiif::KakaduTransformer do
  subject(:instance) { described_class.new(path, image_info, transformation) }

  let(:image_info) { Riiif::ImageInformation.new(6501, 4381) }
  let(:path) { 'baseball.jp2' }
  let(:region) { Riiif::Region::Full.new(image_info) }
  let(:size) { Riiif::Size::Full.new }
  let(:quality) { nil }
  let(:rotation) { nil }
  let(:fmt) { 'jpg' }

  let(:transformation) do
    Riiif::Transformation.new(region,
                              size,
                              quality,
                              rotation,
                              fmt)
  end

  describe '#transform' do
    let(:image_data) { double }

    subject(:transform) { instance.transform }

    before do
      allow(instance).to receive(:with_tempfile).and_yield('/tmp/foo.bmp')
    end

    context 'resize and region' do
      # This is the validator test for size_region
      let(:size) { Riiif::Size::Absolute.new(image_info, 38, 38) }
      let(:region) { Riiif::Region::Absolute.new(image_info, 200, 100, 100, 100) }

      let(:image_info) { Riiif::ImageInformation.new(1000, 1000) }

      it 'calls the Imagemagick transform' do
        expect(Riiif::CommandRunner).to receive(:execute)
          .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 ' \
                '-region "{0.1,0.2},{0.1,0.1}" -reduce 4 -o /tmp/foo.bmp')
        expect(Riiif::CommandRunner).to receive(:execute)
          .with('convert -resize 38x38! -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
        transform
      end
    end

    context 'when reduction_factor is 0' do
      let(:reduction_factor) { 0 }
      context 'and the size is full' do
        it 'calls the Imagemagick transform' do
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -o /tmp/foo.bmp')
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('convert -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
          transform
        end
      end

      context 'and size is a width' do
        let(:size) { Riiif::Size::Width.new(image_info, 651) }
        let(:image_info) { Riiif::ImageInformation.new(1000, 1000) }

        it 'calls the Imagemagick transform' do
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -o /tmp/foo.bmp')
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('convert -resize 651 -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
          transform
        end
      end

      context 'and size is a height' do
        let(:size) { Riiif::Size::Height.new(image_info, 581) }
        let(:image_info) { Riiif::ImageInformation.new(1000, 1000) }

        it 'calls the Imagemagick transform' do
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -o /tmp/foo.bmp')
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('convert -resize x581 -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
          transform
        end
      end
    end

    context 'when reduction_factor is 1' do
      let(:reduction_factor) { 1 }

      context 'and size is a Percent' do
        let(:size) { Riiif::Size::Percent.new(image_info, 30) }

        it 'calls the Imagemagick transform' do
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -reduce 1 -o /tmp/foo.bmp')
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('convert -resize 60.0% -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
          transform
        end
      end

      context 'and size is a width' do
        let(:size) { Riiif::Size::Width.new(image_info, 408) }
        let(:image_info) { Riiif::ImageInformation.new(1000, 1000) }

        it 'calls the Imagemagick transform' do
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -reduce 1 -o /tmp/foo.bmp')
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('convert -resize 408 -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
          transform
        end
      end

      context 'and size is a height' do
        let(:size) { Riiif::Size::Height.new(image_info, 481) }
        let(:image_info) { Riiif::ImageInformation.new(1000, 1000) }

        it 'calls the Imagemagick transform' do
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -reduce 1 -o /tmp/foo.bmp')
          expect(Riiif::CommandRunner).to receive(:execute)
            .with('convert -resize x481 -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
          transform
        end
      end
    end

    context 'when reduction_factor is 2' do
      let(:size) { Riiif::Size::Percent.new(image_info, 20) }
      let(:reduction_factor) { 2 }
      it 'calls the Imagemagick transform' do
        expect(Riiif::CommandRunner).to receive(:execute)
          .with('kdu_expand -quiet -i baseball.jp2 -num_threads 4 -reduce 2 -o /tmp/foo.bmp')
        expect(Riiif::CommandRunner).to receive(:execute)
          .with('convert -resize 80.0% -quality 85 -sampling-factor 4:2:0 -strip /tmp/foo.bmp jpg:-')
        transform
      end
    end
  end
end
