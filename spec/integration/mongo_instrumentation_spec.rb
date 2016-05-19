require 'rails_helper'
require 'active_support/log_subscriber/test_helper'

describe "monitoring mongo query runtimes", type: :request do
  let(:logger) { ActiveSupport::LogSubscriber::TestHelper::MockLogger.new }

  before(:each) do
    @old_logger   = ActionController::Base.logger
    @old_notifier = ActiveSupport::Notifications.notifier

    ActionController::Base.logger = logger
  end

  after(:each) do
    ActionController::Base.logger = @old_logger
    ActiveSupport::Notifications.notifier = @old_notifier
  end

  context "a request that results in mongo queries" do
    let(:content_item) { create(:content_item) }

    before(:each) do
      get content_item_path(content_item)
    end

    it "includes the mongo runtime info in the log output" do
      expect(logger.logged(:info).last).to match(/\(Views: [\d\.]+ms \| Mongo: [\d\.]+ms\)/)

      runtime = logger.logged(:info).last.match(/Mongo: ([\d\.]+)ms/)[1].to_f

      expect(runtime).to be > 0
    end

    it "resets the mongo runtime after the request has completed" do
      expect(MongoInstrumentation::MonitoringSubscriber.runtime).to eq(0)
    end
  end
end
