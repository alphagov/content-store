require "spec_helper"

describe UUIDValidator do

  class PieceOfContent
    include ActiveModel::Model

    attr_accessor :content_id
    validates :content_id, uuid: true
  end

  let(:item) { PieceOfContent.new }

  context "invalid UUIDs" do
    it "rejects nil" do
      item.content_id = nil
      expect(item).not_to be_valid
    end

    it "rejects an empty string" do
      item.content_id = ""
      expect(item).not_to be_valid
    end

    it "rejects a UUID with a bad variant" do
      item.content_id = "11111111-1111-1111-1111-111111111111"
      expect(item).not_to be_valid
    end

    it "rejects a UUID with a bad version number" do
      # The 8 is required for an RFC-compliant UUID; the 6 is a bad version
      item.content_id = "11111111-1111-6111-8111-111111111111"
      expect(item).not_to be_valid
    end

    it "rejects a UUID with extra digits at the end" do
      item.content_id = "27b2ba20-0a08-4fe6-8eb0-68f7f2c9c2c1-c0ffee"
      expect(item).not_to be_valid
    end

    it "rejects a UUID with extra digits at the start" do
      item.content_id = "c0ffee-27b2ba20-0a08-4fe6-8eb0-68f7f2c9c2c1"
      expect(item).not_to be_valid
    end

    it "rejects a UUID with a newline at the end" do
      item.content_id = "27b2ba20-0a08-4fe6-8eb0-68f7f2c9c2c1\n"
      expect(item).not_to be_valid
    end
  end

  context "UUID representations" do
    # These are all valid UUIDs, but we're being strict about the
    # representation, at least for now

    it "accepts a canonical UUID" do
      item.content_id = "27b2ba20-0a08-4fe6-8eb0-68f7f2c9c2c1"
      expect(item).to be_valid
    end

    it "rejects a compact UUID" do
      item.content_id = "27b2ba200a084fe68eb068f7f2c9c2c1"
      expect(item).not_to be_valid
    end

    it "rejects an uppercase UUID" do
      item.content_id = "27B2BA20-0A08-4FE6-8EB0-68F7F2C9C2C1"
      expect(item).not_to be_valid
    end
  end
end
