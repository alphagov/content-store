require "rails_helper"

RSpec.describe SchemaValidator do
  subject(:validator) do
    SchemaValidator.new(rendered_content_item)
  end

  context "schema" do
    let(:rendered_content_item) { { schema_name: 'test' } }

    it "logs to airbrake with an unknown schema_name" do
      expect(Airbrake).to receive(:notify_or_ignore)
        .with(an_instance_of(Errno::ENOENT), a_hash_including(:parameters))
      validator.validate
    end
  end

  context "exceptions" do
    let(:rendered_content_item) { { schema_name: 'placeholder_test' } }

    it "does not report to airbrake" do
      expect(Airbrake).to_not receive(:notify_or_ignore)
      validator.validate
    end
  end
end
