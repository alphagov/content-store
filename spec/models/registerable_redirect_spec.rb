require 'rails_helper'
require 'models/shared_examples/registerable_route_validation'

describe RegisterableRedirect, :type => :model do
  let(:factory_name) { :registerable_redirect }
  it_behaves_like 'a valid registerable route'

  it 'validates destination is an absolute path' do
    route = build(:registerable_redirect, :destination => 'not-absolute-path')

    expect(route).to_not be_valid
    expect(route.errors[:destination].size).to eq(1)
  end
end
