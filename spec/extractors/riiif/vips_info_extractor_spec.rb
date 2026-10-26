require "spec_helper"

RSpec.describe Riiif::VipsInfoExtractor do
  before do
    allow(Riiif::CommandRunner).to receive(:execute).and_return(fake_info)
    allow(Vips::Image).to receive(:new_from_file).and_return(image)
  end

  let(:image) { double(has_alpha?: false, width: 500, height: 376) }

  let(:fake_info) { "tiffload" }

  it "uses vipsheader as its external command" do
    expect(described_class.external_command).to eq "vipsheader"
  end

  context "on a file without transparency" do
    it "returns the extracted attributes" do
      expect(described_class.new("path/to/image.jpg").extract).to eq({
        height: 376,
        width: 500,
        format: "JPEG",
        channels: "srgb"
      })
    end
  end

  context "when autorotate is enabled" do
    let(:oriented) { double(has_alpha?: false, width: 376, height: 500) }

    before do
      allow(Riiif).to receive(:autorotate?).and_return(true)
      allow(image).to receive(:autorot).and_return(oriented)
    end

    it "reports the dimensions after orientation is applied" do
      expect(described_class.new("path/to/image.jpg").extract).to include(width: 376, height: 500)
    end
  end

  context "on a file with transparency" do
    let(:image) { double(has_alpha?: true, width: 50, height: 50) }

    let(:fake_info) { "pngload" }

    it "returns the extracted attributes" do
      expect(described_class.new(image).extract).to eq({
        height: 50,
        width: 50,
        format: "PNG",
        channels: "srgba"
      })
    end
  end
end
