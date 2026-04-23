require "spec_helper"

RSpec.describe Riiif::VipsInfoExtractor do
  before do
    allow(Riiif::CommandRunner).to receive(:execute).and_return(fake_info)
    allow(Vips::Image).to receive(:new_from_file).and_return(image)
  end

  let(:image) { double(has_alpha?: false) }

  let(:fake_info) do
    "500
    376
    tiffload"
  end

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

  context "on a file with transparency" do
    let(:image) { double(has_alpha?: true) }

    let(:fake_info) do
      "50
      50
      pngload"
    end

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
