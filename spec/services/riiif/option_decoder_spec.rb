# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Riiif::OptionDecoder do
  let(:instance) { described_class.new(options, image_info) }
  let(:image_info) { double }
  let(:options) { double }

  describe '#decode_region' do
    subject(:region) { instance.decode_region(value) }

    context 'when passed a percentage' do
      context 'that has int like values' do
        let(:value) { 'pct:1,2,3,4' }
        it 'deals with them' do
          expect(region).to be_kind_of Riiif::Region::Percentage
          expect(region.x_pct).to eq 1.0
          expect(region.y_pct).to eq 2.0
          expect(region.width_pct).to eq 3.0
          expect(region.height_pct).to eq 4.0
        end
      end

      context 'that has float like values' do
        let(:value) { 'pct:1.0,2.3,3.0,4.0' }
        it 'deals with them' do
          expect(region).to be_kind_of Riiif::Region::Percentage
          expect(region.x_pct).to eq 1.0
          expect(region.y_pct).to eq 2.3
          expect(region.width_pct).to eq 3.0
          expect(region.height_pct).to eq 4.0
        end
      end
    end
  end

  describe '#decode_size' do
    subject(:size) { instance.decode_size(value) }

    context 'when passed a percentage' do
      context 'that has int like values' do
        let(:value) { 'pct:10' }
        it 'deals with them' do
          expect(size).to be_kind_of Riiif::Size::Percent
          expect(size.percentage).to eq 10.0
        end
      end

      context 'that has float like values' do
        let(:value) { 'pct:10.0010000' }
        it 'deals with them' do
          expect(size).to be_kind_of Riiif::Size::Percent
          expect(size.percentage).to eq 10.001
        end
      end
    end

    context 'when passed a width' do
      let(:value) { '145,' }

      it 'casts width to an integer' do
        expect(size).to be_kind_of Riiif::Size::Width
        expect(size.width).to eq 145
      end
    end

    context 'when passed a height' do
      let(:value) { ',50' }

      it 'casts height to an integer' do
        expect(size).to be_kind_of Riiif::Size::Height
        expect(size.height).to eq 50
      end
    end

    context 'when passed an absolute' do
      let(:value) { '145,50' }

      it 'casts values to integers' do
        expect(size).to be_kind_of Riiif::Size::Absolute
        expect(size.width).to eq 145
        expect(size.height).to eq 50
      end
    end
  end
end
