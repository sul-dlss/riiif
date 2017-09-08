require 'spec_helper'

RSpec.describe Riiif::Region::Absolute do
  let(:image_info) { double }

  context 'when initialized with strings' do
    let(:instance) { described_class.new(image_info, '5', '15', '50', '100') }

    it 'casts height to an integer' do
      expect(instance.height).to eq 100
    end

    it 'casts width to an integer' do
      expect(instance.width).to eq 50
    end
  end
end
