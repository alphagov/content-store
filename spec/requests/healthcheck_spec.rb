require 'spec_helper'

describe "healthcheck path" do

  it "should respond with 'OK'" do
    get "/healthcheck"

    expect(response).to be_success
    expect(response.body).to eq("OK")
  end
end
