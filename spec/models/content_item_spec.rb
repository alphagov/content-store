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
        let(:attributes) { { "foo" => "foo", "bar" => "bar", "transmitted_at" => 12 } }

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
        let(:attributes) { { "routes" => 12, "transmitted_at" => 12 } }

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
          expect(item.transmitted_at).to eq("1")
        end
      end

      context "with current attributes and a previous item" do
        before do
          @item.save!
        end

        let(:attributes) { @item.attributes.merge("transmitted_at" => "2") }

        it "upserts the item" do
          result = item = nil
          expect {
            result, item = ContentItem.create_or_replace(@item.base_path, attributes)
          }.not_to change(ContentItem, :count)
          expect(result).to eq(:replaced)
          expect(item.transmitted_at).to eq("2")
        end
      end
    end
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

  describe '#linked_items' do
    context 'with no link types' do
      before :each do
        @item = build(:content_item)
      end

      it 'should not return any linked items' do
        expect(@item.linked_items.except("available_translations")).to eq({})
      end
    end

    context 'with an empty link type' do
      before :each do
        @item = build(:content_item)
        @item.links = { "related" => [] }
      end

      it 'should include the key' do
        expect(@item.linked_items.keys).to include("related")
      end

      it 'should have an empty list' do
        expect(@item.linked_items["related"]).to eq([])
      end
    end

    context 'with a published linked item' do
      before :each do
        @linked_item = create(:content_item, :with_content_id)
        @item = build(:content_item)
        @item.links = { "related" => [@linked_item.content_id] }
      end

      it 'should include the key' do
        expect(@item.linked_items.keys).to include("related")
      end

      it 'should include the linked item' do
        expect(@item.linked_items["related"]).to eq([@linked_item])
      end
    end

    context 'with an unpublished linked item' do
      before :each do
        @item = build(
          :content_item,
          links: { "related" => [SecureRandom.uuid] }
        )
      end

      it 'should not include the item' do
        expect(@item.linked_items["related"]).to eq([])
      end
    end

    context 'with a published item and redirects' do
      before :each do
        shared_content_id = SecureRandom.uuid

        # Creating two redirects, one before and one after the content item, so
        # we don't accidentally pass this test by taking the first or last item
        create(
          :redirect_content_item,
          base_path: '/a',
          content_id: shared_content_id
        )
        @linked_item = create(
          :content_item,
          base_path: '/b',
          content_id: shared_content_id
        )
        create(
          :redirect_content_item,
          base_path: '/c',
          content_id: shared_content_id
        )
        @item = build(
          :content_item,
          links: { "related" => [shared_content_id] }
        )
      end

      it 'links to the content item' do
        expect(@item.linked_items["related"]).to eq([@linked_item])
      end
    end

    context 'with non-renderable linked items' do
      let(:redirect) { create(:redirect_content_item, :with_content_id) }
      let(:gone) { create(:gone_content_item, :with_content_id) }
      let(:item) { build(:content_item, links: { "related" => [redirect.content_id, gone.content_id] }) }

      it 'excludes the non-renderable items' do
        expect(item.linked_items["related"]).to eq([])
      end
    end

    context 'with multiple published items' do
      before :each do
        shared_content_id = SecureRandom.uuid
        Timecop.travel(-10.seconds) do
          create(:content_item, base_path: '/a', content_id: shared_content_id)
          create(:content_item, base_path: '/c', content_id: shared_content_id)
        end
        @newer_linked_item = create(
          :content_item,
          base_path: '/b',
          content_id: shared_content_id
        )

        @item = build(
          :content_item,
          links: { "related" => [shared_content_id] }
        )
      end

      it 'takes the most recent' do
        expect(@item.linked_items["related"]).to eq([@newer_linked_item])
      end
    end

    context 'with multiple published items with different locales' do
      let(:shared_content_id) { SecureRandom.uuid }
      let!(:english_linked_item) {
        create(:content_item, base_path: '/a', content_id: shared_content_id, locale: I18n.default_locale.to_s)
      }
      let!(:french_linked_item) {
        create(:content_item, base_path: '/a.fr', content_id: shared_content_id, locale: "fr")
      }
      let(:french_item) {
        build(
          :content_item,
          locale: "fr",
          links: { "related" => [shared_content_id] }
        )
      }
      let(:spanish_item) {
        build(
          :content_item,
          locale: "es",
          links: { "related" => [shared_content_id] }
        )
      }

      it 'takes the one with matching locale if available' do
        expect(french_item.linked_items["related"]).to eq([french_linked_item])
      end

      it 'falls back to the english item if the matching locale is not available' do
        expect(spanish_item.linked_items["related"]).to eq([english_linked_item])
      end

      context "a newer english item exists" do
        let!(:newer_english_linked_item) {
          Timecop.travel(10.seconds) do
            create(:content_item, base_path: '/a_new', content_id: shared_content_id, locale: I18n.default_locale.to_s)
          end
        }

        it 'prefers the newer linked item' do
          expect(spanish_item.linked_items["related"]).to eq([newer_english_linked_item])
        end
      end
    end

    describe 'available_translations' do
      let(:shared_content_id) { SecureRandom.uuid }
      let!(:item_fr) { create(:content_item, locale: 'fr', content_id: shared_content_id) }

      context 'with no translations' do
        it 'should include self in the list of available translations' do
          expect(item_fr.linked_items["available_translations"]).to eq([item_fr])
        end
      end

      context 'with one translation' do
        let!(:item_en) { create(:content_item, locale: 'en', content_id: shared_content_id) }

        it 'should include list of available translations, in alphabetical order of locale' do
          expect(item_en.linked_items["available_translations"]).to eq([item_en, item_fr])
        end
      end

      context 'with multiple translations in the same locale' do
        let!(:item_en) { create(:content_item, locale: 'en', content_id: shared_content_id) }
        let!(:item_fr_new) {
          Timecop.travel(10.seconds) do
            create(:content_item, locale: 'fr', content_id: shared_content_id)
          end
        }

        it 'should prefer the newest item' do
          expect(item_en.linked_items["available_translations"]).to eq([item_en, item_fr_new])
        end
      end

      context 'for an item without a content_id' do
        let!(:item_en) { create(:content_item, locale: 'en', content_id: nil) }
        let!(:other_item_fr) { create(:content_item, locale: 'fr', content_id: nil) }
        let!(:item_en_new) {
          Timecop.travel(10.seconds.from_now) do
            create(:content_item, locale: 'en', content_id: nil)
          end
        }

        it 'should not include available_translations' do
          expect(item_en.linked_items).not_to have_key("available_translations")
        end
      end
    end

    context "if a link hash is provided for pass-through" do
      let(:passthrough_link_hash) {
        {
          content_id: "some-content-id",
          title: "A title",
          description: "A description",
          base_path: nil,
          locale: "fr",
        }
      }

      let!(:content_item) {
        create(:content_item, links: {
          passthrough_links: [passthrough_link_hash]
        })
      }

      it "creates a ContentItem with matching fields" do
        linked_content_item = content_item.linked_items[:passthrough_links].first

        expect(linked_content_item.content_id).to eq("some-content-id")
        expect(linked_content_item.locale).to eq("fr")
        expect(linked_content_item.title).to eq("A title")
        expect(linked_content_item.description).to eq("A description")
        expect(linked_content_item.base_path).to eq(nil)
        expect(linked_content_item.base_path_without_root).to eq(nil)
      end

      context "without a locale specified" do
        let(:passthrough_link_hash) {
          {
            content_id: "some-content-id",
            title: "A title",
            base_path: nil,
          }
        }

        it "defaults the locale to 'en'" do
          linked_content_item = content_item.linked_items[:passthrough_links].first

          expect(linked_content_item.locale).to eq("en")
        end
      end
    end

    context 'formats which should include specific incoming_links' do
      context 'working_group' do
        before :each do
          @working_group = create(:content_item, :with_content_id, format: "working_group")
          @policy = create(:content_item, :with_content_id, format: "policy", links: { "working_groups" => [@working_group.content_id] })
        end

        it 'should include the key' do
          expect(@working_group.linked_items.keys).to include("policies")
        end

        it 'should include the linked item' do
          expect(@working_group.linked_items["policies"]).to eq([@policy])
        end

        describe 'when the item already has links of that type' do
          before :each do
            @another_policy = create(:content_item, :with_content_id, format: "policy")
            @working_group.update(links: { "policies" => [@another_policy.content_id] })
          end

          it 'should append to that list' do
            expect(@working_group.linked_items["policies"]).to include(@policy, @another_policy)
          end
        end

        describe 'when the item links to another policy but with a different link type' do
          before :each do
            @special_policy = create(:content_item, :with_content_id, format: "policy")
            @working_group.update(links: { "special_policies" => [@special_policy.content_id] })
          end

          it 'should not mix them into the policies list' do
            expect(@working_group.linked_items["policies"]).to eq([@policy])
            expect(@working_group.linked_items["special_policies"]).to eq([@special_policy])
          end
        end
      end

      context 'migrated editions' do
        before :each do
          @case_study = create(:content_item, :with_content_id, format: "case_study")
          @document_collection = create(:content_item,
            :with_content_id,
            format: "placeholder_document_collection",
            links: { "documents" => [@case_study.content_id] })
        end

        it 'should include the key' do
          expect(@case_study.linked_items.keys).to include("document_collections")
        end

        it 'should include the linked item' do
          expect(@case_study.linked_items["document_collections"]).to eq([@document_collection])
        end

        describe 'when the item already has links of that type' do
          before :each do
            @another_collection = create(:content_item, :with_content_id, format: "document_collection")
            @case_study.update(links: { "document_collections" => [@another_collection.content_id] })
          end

          it 'should append to that list' do
            expect(@case_study.linked_items["document_collections"]).to include(@document_collection, @another_collection)
          end
        end

        describe 'when the item links to another document_collection but with a different link type' do
          before :each do
            @parent = create(:content_item, :with_content_id, format: "document_collection")
            @case_study.update(links: { "parent" => [@parent.content_id] })
          end

          it 'should not mix them into the document_collections list' do
            expect(@case_study.linked_items["document_collections"]).to eq([@document_collection])
            expect(@case_study.linked_items["parent"]).to eq([@parent])
          end
        end
      end
    end

    context "topics" do
      let(:topic_business_tax) {
        create(
          :content_item,
          content_id: SecureRandom.uuid,
          format: 'topic',
          title: 'Business tax',
          base_path: "/topic/business-tax",
        )
      }

      let(:topic_paye) {
        create(
          :content_item,
          content_id: SecureRandom.uuid,
          format: 'topic',
          title: 'PAYE',
          base_path: "/topic/business-tax/paye",
          links: {
            parent: [topic_business_tax.content_id]
          }
        )
      }

      let(:item) {
        create(
          :content_item,
          links: {
            parent: [
              {
                content_id: topic_paye.content_id,
                title: topic_paye.title,
                base_path: topic_paye.base_path
              }
            ]
          }
        )
      }

      it "ContentItems with parents provide a reference to the main parent" do
        expect(item.linked_parent.content_id).to eq(topic_paye.content_id)
        expect(topic_paye.linked_parent.content_id).to eq(topic_business_tax.content_id)
      end
    end
  end

  describe '#incoming_links' do
    before :each do
      @item = create(:content_item, :with_content_id)
      @other_item = create(:content_item, :with_content_id, links: { "related" => [@item.content_id] })
    end

    it 'should return the linking item' do
      expect(@item.incoming_links("related")).to eq([@other_item])
    end

    context 'with the linking_document_type parameter' do
      before :each do
        create(:content_item, :with_content_id, document_type: "a", links: { "related" => [@item.content_id] })
        @matching = create(:content_item, :with_content_id, document_type: "b", links: { "related" => [@item.content_id] })
      end

      it 'should return only the linking items which have that format' do
        expect(@item.incoming_links("related", linking_document_type: "b")).to eq([@matching])
      end
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

    context 'an access-limited content item' do
      let!(:content_item) { create(:access_limited_content_item) }
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
  end

  describe "description" do
    it "wraps the description as a hash" do
      content_item = FactoryGirl.create(:content_item, description: "foo")

      expect(content_item.description).to eq("foo")
      expect(content_item["description"]).to eq("value" => "foo")
    end
  end
end
