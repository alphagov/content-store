require "rails_helper"

describe MockRouterApi do
  describe "#any_method" do
    let(:an_arbitrary_method_name) { "abcdefghijklmnopqrstuvwxyz_".chars.sample(10).join }

    it "logs the method and arguments with debug level" do
      expect(subject).to receive(:log).with(an_arbitrary_method_name, [1, 2, 3], { keyword: "value" })
      subject.send(an_arbitrary_method_name, 1, 2, 3, keyword: "value")
    end

    it "does not make any requests" do
      expect(a_request(:any, /.*/)).not_to have_been_made
      subject.send(:an_arbitrary_method_name, 1, 2, 3)
    end
  end
end
