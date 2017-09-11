require 'spec_helper'

RSpec.describe Riiif::Size::Absolute do
  let(:image_info) { double }
  let(:instance) { described_class.new(image_info, 50, 100) }
  describe 'height' do
    subject { instance.height }
    it { is_expected.to eq 100 }
  end

  describe 'width' do
    subject { instance.width }
    it { is_expected.to eq 50 }
  end
end
