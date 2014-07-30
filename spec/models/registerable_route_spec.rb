require 'rails_helper'

describe RegisterableRoute, :type => :model do
  it 'validates type is either "exact" or "prefix"' do
    %w(exact prefix).each do |type|
      route = build(:registerable_route, :type => type)
      expect(route).to be_valid
    end

    %w(invalid types).each do |type|
      route = build(:registerable_route, :type => type)
      expect(route).to_not be_valid
      expect(route.errors[:type].size).to eq(1)
    end
  end

  it 'validates path is absolute' do
    route = build(:registerable_route, :path => 'not-absolute-path')

    expect(route).to_not be_valid
    expect(route.errors[:path].size).to eq(1)
  end
end
