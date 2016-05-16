require 'rails_helper'

describe PublishIntent, type: :model do
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
        create(:publish_intent, base_path: "/foo")

        intent.base_path = "/foo"
        expect {
          intent.save! validate: false
        }.to raise_error(Mongo::Error::OperationFailure)
      end
    end

    context "on publish_time" do
      it "should be required" do
        intent.publish_time = nil
        expect(intent).not_to be_valid
        expect(intent.errors[:publish_time].size).to eq(1)
      end
    end

    context "on rendering_app" do
      it "requires a rendering_app" do
        intent.rendering_app = ''
        expect(intent).not_to be_valid
        expect(intent.errors[:rendering_app].size).to eq(1)
      end

      it "requires rendering_app to be a valid DNS hostname" do
        %w(
            word
            alpha12numeric
            dashed-item
        ).each do |value|
          intent.rendering_app = value
          expect(intent).to be_valid
        end

        [
          'no spaces',
          'puncutation!',
          'mixedCASE',
        ].each do |value|
          intent.rendering_app = value
          expect(intent).not_to be_valid
          expect(intent.errors[:rendering_app].size).to eq(1)
        end
      end
    end
  end

  describe "json representation" do
    let(:intent) { build(:publish_intent) }

    it "should replace the _id with base_path" do
      expect(intent.as_json).not_to have_key("_id")
      expect(intent.as_json["base_path"]).to eq(intent.base_path)
    end

    it "should include validation errors if present" do
      intent.publish_time = nil
      intent.valid?

      expect(intent.as_json["errors"]).to eq("publish_time" => ["can't be blank"])
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

  describe "registering routes" do
    let(:routes) do
      [
        { 'path' => '/a-path', 'type' => 'exact' },
        { 'path' => '/a-path.json', 'type' => 'exact' },
        { 'path' => '/a-path/subpath', 'type' => 'prefix' }
      ]
    end

    let(:intent) {
      build(:publish_intent, base_path: "/a-path", rendering_app: "an-app", routes: routes)
    }

    it "registers the assigned routes when created" do
      intent.save!
      assert_routes_registered('an-app', [
        ['/a-path', 'exact'],
        ['/a-path.json', 'exact'],
        ['/a-path/subpath', 'prefix']
      ])
    end
  end

  describe ".cleanup_expired" do
    before :each do
      create(:publish_intent, publish_time: 3.days.ago)
      create(:publish_intent, publish_time: 2.days.ago)
      create(:publish_intent, publish_time: 1.hour.ago)
      create(:publish_intent, publish_time: 10.minutes.from_now)
      create(:publish_intent, publish_time: 10.days.from_now)
      create(:publish_intent, publish_time: 1.year.from_now)
    end

    it "deletes all publish_intents with publish_at in the past" do
      PublishIntent.cleanup_expired

      expect(PublishIntent.count).to eq(3)
      expect(PublishIntent.where(:publish_time.gte => Time.zone.now).count).to eq(3)
    end

    it "does not delete very recently passed intents" do
      recent = create(:publish_intent, publish_time: 30.seconds.ago)

      PublishIntent.cleanup_expired

      expect(PublishIntent.where(base_path: recent.base_path).first).to be
      expect(PublishIntent.count).to eq(4)
    end
  end
end
