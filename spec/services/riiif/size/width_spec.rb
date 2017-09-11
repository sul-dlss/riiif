require 'spec_helper'

RSpec.describe Riiif::Size::Width do
  let(:image_info) { double }
  let(:instance) { described_class.new(image_info, 50) }

  describe 'width' do
    subject { instance.width }
    it { is_expected.to eq 50 }
  end
end
