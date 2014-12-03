require 'rails_helper'

describe PublishIntent, :type => :model do
  describe "validations" do
    let(:intent) { build(:publish_intent) }

    context "on base_path" do
      it "should be required" do
        intent.base_path = nil
        expect(intent).not_to be_valid
        expect(intent.errors[:base_path].size).to eq(1)

        intent.base_path = ''
        expect(intent).not_to be_valid
        expect(intent.errors[:base_path].size).to eq(1)
      end

      it "should be an absolute path" do
        intent.base_path = 'invalid//absolute/path/'
        expect(intent).not_to be_valid
        expect(intent.errors[:base_path].size).to eq(1)
      end

      it "should have a db level uniqueness constraint" do
        create(:publish_intent, :base_path => "/foo")

        intent.base_path = "/foo"
        expect {
          intent.save! :validate => false
        }.to raise_error(Moped::Errors::OperationFailure)
      end
    end

    context "on publish_time" do
      it "should be required" do
        intent.publish_time = nil
        expect(intent).not_to be_valid
        expect(intent.errors[:publish_time].size).to eq(1)
      end
    end
  end

  describe "#past?" do
    let(:intent) { build(:publish_intent) }

    it "is false for an intent in the future" do
      intent.publish_time = 10.minutes.from_now
      expect(intent.past?).to eq(false)
      intent.publish_time = 2.years.from_now
      expect(intent.past?).to eq(false)
    end

    it "is false for an intent set to now" do
      Timecop.freeze do
        intent.publish_time = Time.zone.now
        expect(intent.past?).to eq(false)
      end
    end

    it "is false for an intent only just in the past" do
      Timecop.freeze do
        intent.publish_time = 10.seconds.ago
        expect(intent.past?).to eq(false)
      end
    end

    it "is true for an intent in the past" do
      intent.publish_time = 5.minutes.ago
      expect(intent.past?).to eq(true)

      intent.publish_time = 5.months.ago
      expect(intent.past?).to eq(true)
    end
  end
end
