require 'spec_helper'

RSpec.describe Riiif::Size::Height do
  let(:image_info) { double }

  context 'when initialized with strings' do
    let(:instance) { described_class.new(image_info, '50') }

    it 'casts height to an integer' do
      expect(instance.height).to eq 50
    end
  end
end
