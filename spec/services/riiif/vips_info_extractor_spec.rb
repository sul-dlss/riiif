require 'spec_helper'
require 'ruby-vips'

RSpec.describe Riiif::VipsInfoExtractor do
  it 'uses vipsheader as its external command' do
    expect(described_class.external_command).to eq "vipsheader"
  end

  context 'on a file without transparency' do
    let(:image) { Rails.root.join("spec", "fixtures", "test.tif") }

    it 'returns the extracted attributes' do
      expect(described_class.new(image).extract).to eq({
                                                         height: 376,
                                                         width: 500,
                                                         format: "JPEG",
                                                         channels: "srgb"
                                                       })
    end
  end

  context 'on a file with transparency' do
    let(:image) { Rails.root.join("spec", "fixtures", "test.png") }

    it 'returns the extracted attributes' do
      expect(described_class.new(image).extract).to eq({
                                                         height: 50,
                                                         width: 50,
                                                         format: "PNG",
                                                         channels: "srgba"
                                                       })
    end
  end
end
