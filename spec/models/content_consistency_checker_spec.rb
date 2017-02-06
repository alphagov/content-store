require "rails_helper"

RSpec.describe ContentConsistencyChecker do
  describe "#call" do
    describe "unknown content" do
      subject { described_class.new("/does-not-exist").call }

      it "should have errors" do
        expect(subject).not_to be_empty
      end
    end

    describe "valid content" do
      let(:content_item) { FactoryGirl.create(:content_item) }

      subject { described_class.new(content_item.base_path).call }

      it "should not have errors" do
        stub_router(content_item.base_path)
        expect(subject).to be_empty
      end
    end

    context "has redirects" do
      let(:content_item) { FactoryGirl.create(:redirect_content_item) }

      subject { described_class.new(content_item.base_path).call }

      context "router API does not have an entry for the item" do
        before { stub_router(content_item.base_path, {}, 404) }

        it "should produce an error" do
          expect(subject.first).to match(/not found/)
        end
      end

      context "router API handler is not marked as a redirect" do
        before { stub_router(content_item.base_path) }

        it "should produce an error" do
          expect(subject.first).to match(/Handler is not a redirect for/)
        end
      end

      context "router API redirect destination does not match" do
        before do
          stub_router(
            content_item.base_path,
            handler: "redirect",
            redirect_to: "/somewhere-else",
          )
        end

        it "should produce an error" do
          expect(subject.first).to match(/does not match item destination/)
        end
      end
    end

    context "has routes" do
      let(:content_item) { FactoryGirl.create(:content_item) }

      subject { described_class.new(content_item.base_path).call }

      context "router API does not have an entry for the item" do
        before do
          stub_router(content_item.base_path, {}, 404)
        end

        it "should produce an error" do
          expect(subject.first).to match(/not found/)
        end
      end

      context "router API does not have an entry for the item" do
        before do
          stub_router(content_item.base_path, backend_id: "falafel")
        end

        it "should produce an error" do
          expect(subject.first).to match(/does not match item rendering app/)
        end
      end

      context "router API has item marked as disabled" do
        before do
          stub_router(content_item.base_path, disabled: true)
        end

        it "should produce an error" do
          expect(subject.first).to match(/is marked as disabled/)
        end
      end

      context "router API has a different handler" do
        before do
          stub_router(
            content_item.base_path,
            handler: "redirect",
            incoming_path: content_item.base_path,
          )
        end

        it "should produce an error" do
          expect(subject.first).to match(/does not match expected item handler/)
        end
      end

      context "router API has a different handler for a gone item" do
        let(:content_item) { FactoryGirl.create(:gone_content_item) }
        before do
          stub_router(
            content_item.base_path,
            handler: "backend",
            incoming_path: content_item.base_path,
          )
        end

        it "should produce an error" do
          expect(subject.first).to match(/does not match expected item handler/)
        end
      end
    end
  end
end

def router_api_url
  Plek.find('router-api')
end

def default_router_body
  {
    backend_id: "frontend",
    disabled: false,
    handler: "backend",
    route_type: "exact",
  }
end

def stub_router(path = "/test-redirect", body_args = {}, status = 200)
  body = default_router_body.merge(incoming_path: path).merge(body_args)
  stub_request(:get, "#{router_api_url}/routes?incoming_path=#{path}").
    and_return(
      status: status,
      body: body.to_json,
      headers: { "Content-Type": "application/json" }
    )
end
