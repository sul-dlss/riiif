require 'spec_helper'
require 'ruby-vips'

RSpec.describe Riiif::VipsTransformer do
  let(:channels) { 'rgb' }

  let(:path) { Rails.root.join("spec", "fixtures", "test.tif").to_s }

  let(:image_info) { double({ height: Vips::Image.new_from_file(path).height,
                              width: Vips::Image.new_from_file(path).width,
                              format: 'jpg',
                              channels: channels }) }

  let(:target) { 'jpg' }

  let(:transformation) do
    IIIF::Image::Transformation.new(region: region,
                                    size: size,
                                    rotation: rotation,
                                    format: target)
  end

  # Default/Placeholder values that should be modified in tests
  let(:size) { IIIF::Image::Size::Full.new }
  let(:region) { IIIF::Image::Region::Full.new }
  let(:rotation) { 0 }

  describe '#transform' do
    subject { described_class.new(path, image_info, transformation).transform }
    before { allow_any_instance_of(Vips::Image).to receive(:write_to_buffer) }
    after { subject }

    context 'when requesting jpg format with default options' do
      it 'writes to jpg format' do
        expect_any_instance_of(Vips::Image).to receive(:write_to_buffer).with(".jpg[Q=85,optimize-coding,strip]")
      end
    end

    context 'when requesting png format with default options' do
      let(:target) { 'png' }

      it 'writes to png format' do
        expect_any_instance_of(Vips::Image).to receive(:write_to_buffer).with(".png[Q=85,optimize-coding,strip]")
      end
    end

    context 'when requesting jpeg format for a png' do
      let(:path) { Rails.root.join("spec", "fixtures", "test.png").to_s }

      it 'writes to png anyway to preserve transparency' do
        expect_any_instance_of(Vips::Image).to receive(:write_to_buffer).with(".png[Q=85,optimize-coding,strip]")
      end
    end

    context 'with subsampling turned off' do
      subject { described_class.new(path, image_info, transformation, subsample: false).transform }

      it 'does not subsample' do
        expect_any_instance_of(Vips::Image).to receive(:write_to_buffer).with(".jpg[Q=85,optimize-coding,strip,no-subsample]")
      end
    end

    context 'when specifying compression factor' do
      subject { described_class.new(path, image_info, transformation, compression: 90).transform }

      it 'compresses to the correct quality' do
        expect_any_instance_of(Vips::Image).to receive(:write_to_buffer).with(".jpg[Q=90,optimize-coding,strip]")
      end
    end

    context 'when strip_metadata is false' do
      subject { described_class.new(path, image_info, transformation, strip_metadata: false).transform }

      it 'does not strip metadata' do
        expect_any_instance_of(Vips::Image).to receive(:write_to_buffer).with(".jpg[Q=85,optimize-coding]")
      end
    end
  end

  describe '#transform_image' do
    subject { described_class.new(path, image_info, transformation).send(:transform_image) }

    describe 'resize' do
      context 'when specifing full size' do

        it 'does not resize' do
          expect_any_instance_of(Vips::Image).not_to receive(:resize)
          expect_any_instance_of(Vips::Image).not_to receive(:thumbnail_image)
          subject
        end
      end

      context 'when specifing percent size' do
        let(:size) { IIIF::Image::Size::Percent.new(50) }

        it 'resizes the image' do
          expect_any_instance_of(Vips::Image).to receive(:resize).with(50.0)
          expect_any_instance_of(Vips::Image).not_to receive(:thumbnail_image)
          subject
        end
      end

      context 'when specifing float percent size' do
        let(:size) { IIIF::Image::Size::Percent.new(12.5) }

        it 'resizes the image' do
          expect_any_instance_of(Vips::Image).to receive(:resize).with(12.5)
          expect_any_instance_of(Vips::Image).not_to receive(:thumbnail_image)
          subject
        end
      end

      context 'when specifying width and/or height' do

        context 'when specifing w, size' do
          let(:size) { IIIF::Image::Size::Width.new(300) }

          it 'resizes the image to 300px wide, maintaining aspect ratio' do
            expect(subject.width).to eq 300
            expect(subject.height).to eq 226
          end
        end

        context 'when specifing ,h size' do
          let(:size) { IIIF::Image::Size::Height.new(300) }

          it 'resizes the image to 300px high, maintaining aspect ratio' do
            expect(subject.width).to eq 399
            expect(subject.height).to eq 300
          end
        end

        context 'when specifing absolute w,h size' do
          let(:size) { IIIF::Image::Size::Absolute.new(200, 300) }

          it 'resizes the image, ignoring aspect ratio' do
            expect(subject.width).to eq 200
            expect(subject.height).to eq 300
          end
        end

        context 'when specifing bestfit (!w,h) size' do
          let(:size) { IIIF::Image::Size::BestFit.new(200, 300) }

          it 'resizes the image so that the width and height are equal or less than the requested value' do
            expect(subject.width).to eq 200
            expect(subject.height).to eq 150
          end
        end
      end

    end

    describe 'crop' do
      after { subject }

      context 'when specifing full size' do
        let(:region) { IIIF::Image::Region::Full.new }

        it 'does not crop' do
          expect_any_instance_of(Vips::Image).not_to receive(:crop)
        end
      end

      context 'when specifing absolute geometry' do
        let(:region) { IIIF::Image::Region::Absolute.new(80, 15, 60, 75) }

        it 'crops to that region' do
          expect_any_instance_of(Vips::Image).to receive(:crop).with(80, 15, 60, 75)
        end
      end

      context 'when specifing percent geometry' do
        let(:region) { IIIF::Image::Region::Percent.new(10, 10, 80, 70) }
        before { allow(image_info).to receive_messages(width: 100, height: 100, format: 'jpeg', channels: channels) }

        it 'crops to that region' do
          expect_any_instance_of(Vips::Image).to receive(:crop).with(10, 10, 80, 70)
        end
      end

      context 'when specifing square geometry' do
        let(:region) { IIIF::Image::Region::Square.new }

        it 'crops a square the size of the shortest edge' do
          expect_any_instance_of(Vips::Image).to receive(:crop).with(62, 0, 376, 376)
        end
      end
    end

    describe 'rotate' do
      after { subject }

      context 'when no rotation (0) is specified' do
        it 'does not rotate' do
          expect_any_instance_of(Vips::Image).not_to receive(:rotate)
        end
      end

      context 'when rotation is specified' do
        let(:rotation) { 45 }

        it 'rotates the image' do
          expect_any_instance_of(Vips::Image).to receive(:rotate).with(45)
        end
      end

    end

    describe 'colourspace' do
      after { subject }

      context 'when quality is default or color' do
        it 'leaves the image in color' do
          expect_any_instance_of(Vips::Image).not_to receive(:colourspace).with(:b_w)
          expect_any_instance_of(Vips::Image).not_to receive(:>)
        end
      end

      context 'when quality is gray' do
        let(:transformation) { IIIF::Image::Transformation.new(region: region, size: size, rotation: rotation, quality: 'gray') }

        it 'makes the image grayscale' do
          expect_any_instance_of(Vips::Image).to receive(:colourspace).with(:b_w)
        end
      end

      context 'when quality is bitonal' do
        let(:transformation) { IIIF::Image::Transformation.new(region: region, size: size, rotation: rotation, quality: 'bitonal') }
        before { allow_any_instance_of(Vips::Image).to receive(:colourspace).and_return(Vips::Image.new_from_file(path)) }

        it 'makes the image bitonal' do
          expect_any_instance_of(Vips::Image).to receive(:colourspace).with(:b_w)
          expect_any_instance_of(Vips::Image).to receive(:>).with(200)
        end
      end

    end
  end
end