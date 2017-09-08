require 'spec_helper'

RSpec.describe Riiif::Size::Width do
  let(:image_info) { double }

  context 'when initialized with strings' do
    let(:instance) { described_class.new(image_info, '50') }

    it 'casts height to an integer' do
      expect(instance.width).to eq 50
    end
  end
end
