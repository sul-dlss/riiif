RSpec.describe Riiif::ImageMagickInfoExtractor do
  it "uses identify as its external command" do
    expect(described_class.external_command).to eq "identify"
  end

  context "when autorotate is enabled" do
    before { allow(Riiif).to receive(:autorotate?).and_return(true) }

    it "asks identify to auto-orient" do
      expect(Riiif::CommandRunner).to receive(:execute).with(/\Aidentify -auto-orient /).and_return("376 500 JPEG srgb")
      expect(described_class.new("x.jpg").extract).to include(width: 500, height: 376)
    end
  end

  context "with a jpg" do
    let(:image) { Rails.root.join("spec", "fixtures", "test.jpg") }

    it "returns the extracted attributes" do
      expect(described_class.new(image).extract).to eq({
        height: 397,
        width: 300,
        format: "JPEG",
        channels: "srgb"
      })
    end
  end

  context "with a png" do
    let(:image) { Rails.root.join("spec", "fixtures", "test.png") }

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
