require 'spec_helper'

RSpec.describe Riiif::Size::Height do
  let(:image_info) { double }
  let(:instance) { described_class.new(image_info, 100) }

  describe 'height' do
    subject { instance.height }
    it { is_expected.to eq 100 }
  end
end
