require "rails_helper"

RSpec.describe ExpandedLinksPresenter do
  describe ".present" do
    subject { described_class.new(links).present }

    let(:prefix) { Plek.website_root }
    let(:base_path) { "/test-page" }
    let(:api_path) { "/api/content/test-page" }
    let(:links) do
      {
        link_group: [{ base_path:, api_path: }],
      }
    end

    context "production environment" do
      let(:production_prefix) { "https://www.gov.uk" }
      let(:expected) do
        {
          link_group: [
            a_hash_including(
              web_url: "#{production_prefix}#{base_path}",
              api_url: "#{production_prefix}#{api_path}",
            ),
          ],
        }
      end

      before { allow(Plek).to receive(:website_root).and_return(production_prefix) }

      it { is_expected.to include expected }
    end

    context "development environment" do
      let(:development_prefix) { "http://dev.gov.uk" }
      let(:expected) do
        {
          link_group: [
            a_hash_including(
              web_url: "#{development_prefix}#{base_path}",
              api_url: "#{development_prefix}#{api_path}",
            ),
          ],
        }
      end

      before { allow(Plek).to receive(:website_root).and_return(development_prefix) }

      it { is_expected.to include expected }
    end

    context "links with arbitrary custom fields" do
      let(:links) do
        {
          link_group: [{ foo: "bar", auth_bypass_ids: "secret" }],
        }
      end

      subject { described_class.new(links).present[:link_group][0] }

      it "contains the custom fields but does not contain fields marked as secret" do
        is_expected.to include(:foo)
        is_expected.not_to include(:auth_bypass_ids)
      end
    end

    context "groups of links" do
      let(:links) do
        {
          group_1: [
            { base_path: "/group-1/link-1", api_path: "/api/content/group-1/link-1" },
            { base_path: "/group-1/link-2", api_path: "/api/content/group-1/link-2" },
            { base_path: "/group-1/link-3", api_path: "/api/content/group-1/link-3" },
          ],
          group_2: [
            { base_path: "/group-2/link-1", api_path: "/api/content/group-2/link-1" },
            { base_path: "/group-2/link-2", api_path: "/api/content/group-2/link-2" },
            { base_path: "/group-2/link-3", api_path: "/api/content/group-2/link-3" },
          ],
        }
      end

      let(:expected) do
        {
          group_1: [
            a_hash_including(web_url: "#{prefix}/group-1/link-1", api_url: "#{prefix}/api/content/group-1/link-1"),
            a_hash_including(web_url: "#{prefix}/group-1/link-2", api_url: "#{prefix}/api/content/group-1/link-2"),
            a_hash_including(web_url: "#{prefix}/group-1/link-3", api_url: "#{prefix}/api/content/group-1/link-3"),
          ],
          group_2: [
            a_hash_including(web_url: "#{prefix}/group-2/link-1", api_url: "#{prefix}/api/content/group-2/link-1"),
            a_hash_including(web_url: "#{prefix}/group-2/link-2", api_url: "#{prefix}/api/content/group-2/link-2"),
            a_hash_including(web_url: "#{prefix}/group-2/link-3", api_url: "#{prefix}/api/content/group-2/link-3"),
          ],
        }
      end

      it { is_expected.to match expected }
    end

    context "link without api_path set" do
      let(:links) do
        {
          link_group: [{ base_path: }],
        }
      end
      let(:api_path) { "/api/content#{base_path}" }
      let(:expected) do
        {
          link_group: [
            a_hash_including(
              api_path:,
              api_url: "#{prefix}#{api_path}",
            ),
          ],
        }
      end

      it "prefixes a base path with '/api/content' to create API url" do
        is_expected.to match expected
      end
    end

    context "link without base_path" do
      let(:links) do
        {
          link_group: [{}],
        }
      end

      let(:expected_links) do
        {
          link_group: [
            {
              links: {},
            },
          ],
        }
      end

      it "does not include api_path, api_url or web_url" do
        is_expected.to match expected_links
      end
    end

    context "link with children" do
      let(:links) do
        { group: [{ base_path: "/grand-parent", links: parent }] }
      end

      let(:parent) do
        { group: [{ base_path: "/grand-parent/parent", links: child }] }
      end

      let(:child) do
        { group: [{ base_path: "/grand-parent/parent/child", links: {} }] }
      end

      let(:expected_links) do
        {
          group: [
            a_hash_including(
              web_url: "#{prefix}/grand-parent",
              links: expected_parent,
            ),
          ],
        }
      end

      let(:expected_parent) do
        {
          group: [
            a_hash_including(
              web_url: "#{prefix}/grand-parent/parent",
              links: expected_child,
            ),
          ],
        }
      end

      let(:expected_child) do
        {
          group: [
            a_hash_including(
              web_url: "#{prefix}/grand-parent/parent/child",
              links: {},
            ),
          ],
        }
      end

      it { is_expected.to match expected_links }
    end
  end

  # PR #1096 caused the second-level links to disappear, but the tests all passed (incident 2023-06-27)
  # This test added to catch that problem in future, using the JSON from the actual content_item
  # on which the problem was identified
  context "when the links has role_appointments and the role_appointments have links" do
    let(:links_json) { File.read(Rails.root.join("spec/fixtures/content_item_links_with_role_appointments.json")) }
    let(:links) { JSON.parse(links_json) }

    describe "the result" do
      let(:result) { described_class.new(links).present }

      it "has the expected links-within-links" do
        expect(result[:role_appointments].any? { |ra| ra[:links].empty? }).to eq(false)
      end
    end
  end
end
