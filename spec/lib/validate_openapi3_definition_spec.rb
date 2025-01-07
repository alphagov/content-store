require "rails_helper"

describe "Validate OpenAPI 3.0 definition" do
  it "the definition contains no errors" do
    parser = Openapi3Parser.load_file("openapi.yaml")

    expect(parser).to be_valid
  end
end
