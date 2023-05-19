require "rails_helper"

describe MockRouterApi do
  describe "#delete_route" do
    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with("delete_route", [1, 2, 3])
      subject.delete_route(1, 2, 3)
    end

    it "does not make any requests" do
      expect(a_request(:any, "*")).not_to have_been_made
      subject.delete_route(1, 2, 3)
    end
  end

  describe "#add_backend" do
    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with("add_backend", [1, 2, 3])
      subject.add_backend(1, 2, 3)
    end

    it "does not make any requests" do
      expect(a_request(:any, "*")).not_to have_been_made
      subject.add_backend(1, 2, 3)
    end
  end

  describe "#add_redirect_route" do
    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with("add_redirect_route", [1, 2, 3])
      subject.add_redirect_route(1, 2, 3)
    end

    it "does not make any requests" do
      expect(a_request(:any, "*")).not_to have_been_made
      subject.add_redirect_route(1, 2, 3)
    end
  end

  describe "#add_gone_route" do
    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with("add_gone_route", [1, 2, 3])
      subject.add_gone_route(1, 2, 3)
    end

    it "does not make any requests" do
      expect(a_request(:any, "*")).not_to have_been_made
      subject.add_gone_route(1, 2, 3)
    end
  end

  describe "#add_route" do
    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with("add_route", [1, 2, 3])
      subject.add_route(1, 2, 3)
    end

    it "does not make any requests" do
      expect(a_request(:any, "*")).not_to have_been_made
      subject.add_route(1, 2, 3)
    end
  end

  describe "#commit_routes" do
    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with("commit_routes", [1, 2, 3])
      subject.commit_routes(1, 2, 3)
    end

    it "does not make any requests" do
      expect(a_request(:any, "*")).not_to have_been_made
      subject.commit_routes(1, 2, 3)
    end
  end
end
