require 'rails_helper'
require 'update_lock'

describe ContentItem, type: :model do
  describe ".create_or_replace" do
    describe "exceptions" do
      before :each do
        @item = build(:content_item)
        allow_any_instance_of(UpdateLock)
          .to receive(:check_availability!)
      end

      context "when unknown attributes are provided" do
        let(:attributes) { { "foo" => "foo", "bar" => "bar" } }

        it "handles Mongoid::Errors::UnknownAttribute" do
          result = item = nil

          expect {
            result, item = ContentItem.create_or_replace(@item.base_path, attributes)
          }.to_not raise_error

          expect(result).to be false
          expect(item.errors[:base]).to include('unrecognised field(s) foo, bar in input')
        end
      end

      context "when assigning a value of incorrect type" do
        let(:attributes) { { "routes" => 12 } }

        it "handles Mongoid::Errors::InvalidValue" do
          result = item = nil

          expect {
            # routes should be of type Array
            result, item = ContentItem.create_or_replace(@item.base_path, attributes)
          }.to_not raise_error

          expect(result).to be false
          expected_error_message = Mongoid::Errors::InvalidValue.new(Array, 12.class).message
          expect(item.errors[:base]).to include(expected_error_message)
        end
      end

      context "when UpdateLock raises an OutOfOrderTransmissionError" do
        before do
          allow_any_instance_of(UpdateLock)
            .to receive(:check_availability!)
            .and_raise(OutOfOrderTransmissionError, "Booyah")
        end

        it "returns a result of :conflict" do
          result, item = ContentItem.create_or_replace(@item.base_path, {})

          expect(result).to eq(:conflict)
          expect(item.errors[:message]).to include("Booyah")
        end
      end

      context "with current attributes and no previous item" do
        let(:attributes) { @item.attributes }

        it "upserts the item" do
          result = item = nil
          expect {
            result, item = ContentItem.create_or_replace(@item.base_path, attributes)
          }.to change(ContentItem, :count).by(1)
          expect(result).to eq(:created)
        end
      end

      context "with current attributes and a previous item" do
        before do
          @item.save!
        end

        let(:attributes) { @item.attributes }

        it "upserts the item" do
          result = item = nil
          expect {
            result, item = ContentItem.create_or_replace(@item.base_path, attributes)
          }.not_to change(ContentItem, :count)
          expect(result).to eq(:replaced)
        end
      end
    end
  end

  describe ".find_by_path" do
    subject { described_class.find_by_path(path) }
    it_behaves_like "find_by_path", :content_item
  end

  it "should set updated_at on upsert" do
    item = build(:content_item)
    Timecop.freeze do
      item.upsert
      item.reload

      expect(item.updated_at.to_s).to eq(Time.zone.now.to_s)
    end
  end

  describe "registering routes" do
    before do
      @routes = [
        { 'path' => '/a-path', 'type' => 'exact' },
        { 'path' => '/a-path.json', 'type' => 'exact' },
        { 'path' => '/a-path/subpath', 'type' => 'prefix' }
      ]

      @item = build(:content_item, base_path: '/a-path', rendering_app: 'an-app', routes: @routes)
    end

    it 'registers the assigned routes' do
      @item.register_routes
      assert_routes_registered('an-app', [
        ['/a-path', 'exact'],
        ['/a-path.json', 'exact'],
        ['/a-path/subpath', 'prefix']
      ])
    end

    context "with a previous item" do
      before :each do
        # dup the routes so they can be modified without affecting @item
        previous_routes = @routes.map(&:dup)
        @previous_item = build(:content_item, base_path: '/a-path', rendering_app: 'an-app', routes: previous_routes)
      end

      it 'does not register the routes when they are unchanged' do
        @item.register_routes(previous_item: @previous_item)
        refute_routes_registered('an-app', [
          ['/a-path', 'exact'],
          ['/a-path.json', 'exact'],
          ['/a-path/subpath', 'prefix']
        ])
      end

      it 'registers routes when the routes are different' do
        @previous_item.routes[1]['type'] = 'prefix'
        @item.register_routes(previous_item: @previous_item)
        assert_routes_registered('an-app', [
          ['/a-path', 'exact'],
          ['/a-path.json', 'exact'],
          ['/a-path/subpath', 'prefix']
        ])
      end

      it 'registers routes when the redirects are different' do
        @previous_item.redirects << { 'path' => '/a-path/old-part', 'type' => 'exact', 'destination' => '/somewhere' }
        @item.register_routes(previous_item: @previous_item)
        assert_routes_registered('an-app', [
          ['/a-path', 'exact'],
          ['/a-path.json', 'exact'],
          ['/a-path/subpath', 'prefix']
        ])
      end

      it 'registers routes when the rendering_app is different' do
        @previous_item.rendering_app = 'another-app'
        @item.register_routes(previous_item: @previous_item)
        assert_routes_registered('an-app', [
          ['/a-path', 'exact'],
          ['/a-path.json', 'exact'],
          ['/a-path/subpath', 'prefix']
        ])
      end
    end

    context "when previous item is a placeholder" do
      before :each do
        previous_routes = @routes.map(&:dup)
        @previous_item = build(:content_item, base_path: '/a-path', rendering_app: 'an-app', format: "placeholder", routes: previous_routes)
      end

      it "registers routes even though they haven't changed" do
        @item.register_routes(previous_item: @previous_item)
        assert_routes_registered('an-app', [
          ['/a-path', 'exact'],
          ['/a-path.json', 'exact'],
        ])
      end
    end
  end


  context 'when loaded from the content store' do
    before do
      create(:content_item, base_path: '/base_path', routes: [{ 'path' => '/base_path', 'type' => 'exact' }])
      @item = ContentItem.last
    end

    it "should be valid" do
      expect(@item).to be_valid
    end
  end

  describe 'access limiting' do
    context 'a content item that is not access limited' do
      let!(:content_item) { create(:content_item) }

      it 'is not access limited' do
        expect(content_item.access_limited?).to be(false)
      end

      it 'is viewable by all' do
        expect(content_item.viewable_by?(nil)).to be(true)
        expect(content_item.viewable_by?('a-user-uid')).to be(true)
      end
    end

    context 'an access-limited by user-id content item' do
      let!(:content_item) { create(:access_limited_content_item, :by_user_id) }
      let(:authorised_user_uid) { content_item.access_limited['users'].first }

      it 'is access limited' do
        expect(content_item.access_limited?).to be(true)
      end

      it 'is viewable by an authorised user' do
        expect(content_item.viewable_by?(authorised_user_uid)).to be(true)
      end

      it 'is not viewable by an unauthorised user' do
        expect(content_item.viewable_by?('unauthorised-user')).to be(false)
        expect(content_item.viewable_by?(nil)).to be(false)
      end
    end

    context "an access-limited by auth_bypass_id content item" do
      let!(:content_item) { create(:access_limited_content_item, :by_auth_bypass_id) }
      let(:auth_bypass_id) { content_item.access_limited['auth_bypass_ids'].first }
      let(:logged_in_user) { 'authenticated_user_uid' }

      it "is access limited" do
        expect(content_item.access_limited?).to be(true)
      end

      it "includes a valid auth_bypass_id" do
        expect(content_item.includes_auth_bypass_id?(auth_bypass_id)).to be(true)
      end

      it "does not include a valid auth bypass token when the id is invalid" do
        expect(content_item.includes_auth_bypass_id?("foo")).to be(false)
      end

      it 'is viewable by an authenticated user' do
        expect(content_item.viewable_by?(logged_in_user)).to be(true)
      end
    end
  end

  describe "description" do
    it "wraps the description as a hash" do
      content_item = FactoryBot.create(:content_item, description: "foo")

      expect(content_item.description).to eq("foo")
      expect(content_item["description"]).to eq("value" => "foo")
    end
  end

  describe "gone?" do
    it "returns true for schema_name 'gone' with no details" do
      gone_item = build(:gone_content_item)
      expect(gone_item.gone?).to be(true)
    end

    it "returns false for schema_name 'gone' with details" do
      gone_item = build(:gone_content_item_with_details)
      expect(gone_item.gone?).to be(false)
    end

    it "returns true for schema_name 'gone' with empty details fields" do
      gone_item = build(:gone_content_time_with_empty_details_fields)
      expect(gone_item.gone?).to be(true)
    end
  end
end
