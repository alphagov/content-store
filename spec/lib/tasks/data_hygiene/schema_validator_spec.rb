require "rails_helper"

RSpec.describe Tasks::DataHygiene::SchemaValidator, :report_errors do
  let(:csv_file) { double(:csv_file) }
  let(:log) { double(:log) }

  let(:schema) do
    {
      "type" => "object",
      "required" => %w[title],
      "properties" => {
        "title" => { "type" => "string" },
      },
    }
  end

  before do
    FactoryBot.create(:content_item, schema_name: "some_format")

    allow(File).to receive(:open)
      .with(Rails.root.join("tmp/some_format-validation-errors.csv"), "w")
      .and_yield(csv_file)

    allow(File).to receive(:read).with(%r{/formats/some_format/frontend/schema.json$})
      .and_return(schema.to_json)

    expect(log).to receive(:puts)
      .with("Validating 1 items with format 'some_format'\n\n")
  end

  context "with a valid payload" do
    it "doesn't log to file" do
      expect(log).to receive(:puts)
        .with(a_string_matching(/0 errors written/))

      expect(log).to receive(:print).with(".")
      expect(csv_file).not_to receive(:write).with(anything)

      described_class.new("some_format", log).report_errors
    end
  end

  context "with an invalid payload" do
    let(:schema) do
      {
        "type" => "object",
        "required" => %w[a],
        "properties" => {
          "a" => { "type" => "integer" },
        },
      }
    end

    it "logs errors to file" do
      expect(log).to receive(:puts)
        .with(a_string_matching(/1 errors written/))

      expect(log).to receive(:print).with("E")
      expect(csv_file).to receive(:write)
        .with(a_string_matching(/property '#\/' did not contain a required property of 'a'/))

      described_class.new("some_format", log).report_errors
    end
  end
end
