require "rails_helper"

describe ContentStore::Application, "configuration" do
  let(:config) { Rails.application }

  describe "#router_api" do
    context "when DISABLE_ROUTER_API is 'true'" do
      around do |t|
        ClimateControl.modify DISABLE_ROUTER_API: "true" do
          t.run
        end
      end

      it "returns a MockRouterApi" do
        expect(config.router_api).to be_a(MockRouterApi)
      end
    end

    context "when DISABLE_ROUTER_API is not 'true'" do
      around do |t|
        ClimateControl.modify DISABLE_ROUTER_API: "" do
          t.run
        end
      end

      it "returns an instance of what GdsApi.router returns" do
        expect(config.router_api).to be_a(GdsApi.router.class)
      end
    end
  end
end
