require 'rails_helper'
require 'models/shared_examples/registerable_route_validation'

describe RegisterableGoneRoute, :type => :model do
  let(:factory_name) { :registerable_gone_route }
  it_behaves_like 'a valid registerable route'
end
