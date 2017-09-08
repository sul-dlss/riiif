# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Riiif::Transformation do
  subject(:transformation) do
    Riiif::Transformation.new(region,
                              size,
                              quality,
                              rotation,
                              fmt)
  end

  let(:region) { Riiif::Region::Full.new(image_info) }
  let(:size) { Riiif::Size::Percent.new(image_info, 20) }
  let(:quality) { nil }
  let(:rotation) { nil }
  let(:fmt) { nil }
  let(:image_info) { double('Image info', height: 4381, width: 6501) }

  describe 'reduce' do
    subject { transformation.reduce(factor) }
    context 'when reduced by 2' do
      let(:factor) { 2 }
      let(:size) { Riiif::Size::Percent.new(image_info, 20) }

      it 'downsamples the size' do
        expect(subject.size).to be_kind_of Riiif::Size::Percent
        expect(subject.size.percentage).to eq 80.0
      end
    end
  end

  describe 'without_crop' do
    let(:region) { Riiif::Region::Absolute.new(image_info, 5, 6, 7, 8) }

    subject { transformation.without_crop(image_info) }
    it 'nullifies the crop' do
      expect(subject.crop).to be_kind_of Riiif::Region::Full
    end
  end
end
