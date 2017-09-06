# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Riiif::KakaduCommandFactory do
  subject { described_class.build(path, info, transformation) }

  let(:info) { double(:info) }
  let(:path) { 'foo.jp2' }
  let(:region) { Riiif::Region::Full.new(info) }
  let(:size) { Riiif::Size::Full.new }
  let(:quality) { nil }
  let(:rotation) { nil }
  let(:fmt) { nil }

  let(:transformation) do
    Riiif::Transformation.new(region,
                              size,
                              quality,
                              rotation,
                              fmt)
  end

  describe '#build' do
    before do
      allow(::File).to receive(:symlink)
      allow(Riiif::LinkNameService).to receive(:create).and_return('/tmp/bar.bmp')
    end

    context 'with a full size image' do
      it { is_expected.to eq 'kdu_expand -quiet -i foo.jp2 -num_threads 4 -o /tmp/bar.bmp' }
    end
  end

  describe '#region' do
    subject { instance.send(:region) }
    let(:info) { double(height: 300, width: 300) }

    context 'with a full' do
      it { is_expected.to be nil }
    end

    context 'with absolute' do
      let(:region) { Riiif::Region::Absolute.new(info, 25, 75, 150, 100) }
      it { is_expected.to eq ' -region {0.25,0.08333333333333333},{0.3333333333333333,0.5}' }
    end

    context 'with a square' do
      let(:region) { Riiif::Region::Square.new(info) }
      it { is_expected.to eq ' -region {0.0,0},{1.0,1.0}' }
    end

    context 'with a percentage' do
      let(:region) { Riiif::Region::Percentage.new(info, 20, 30, 40, 50) }
      it { is_expected.to eq ' -region {0.3,0.2},{0.5,0.4}' }
    end
  end

  describe '#reduction_arg' do
    subject { instance.send(:reduction_arg) }

    let(:instance) { described_class.new(path, info, transformation) }
    let(:info) { Riiif::ImageInformation.new(300, 300) }

    context 'for a full size image' do
      it { is_expected.to eq nil }
    end

    context 'when the aspect ratio is maintined for absolute' do
      let(:size) { Riiif::Size::Absolute.new(info, 145, 145) }
      it { is_expected.to eq 1 }
    end

    context 'when the aspect ratio is not-maintined' do
      let(:size) { Riiif::Size::Absolute.new(info, 100, 145) }
      it { is_expected.to eq nil }
    end

    context 'when aspect ratio is maintained for 45 pct' do
      let(:size) { Riiif::Size::Percent.new(info, 45) }
      it { is_expected.to eq 1 }
    end

    context 'when aspect ratio is maintained for 20 pct' do
      let(:size) { Riiif::Size::Percent.new(info, 20) }
      it { is_expected.to eq 2 }
    end
  end
end
