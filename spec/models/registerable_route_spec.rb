require 'spec_helper'

describe RegisterableRoute do
  it 'validates type is either "exact" or "prefix"' do
    %w(exact prefix).each do |type|
      expect(RegisterableRoute.new('/path', type, 'app')).to be_valid
    end

    %w(invalid types).each do |type|
      route = RegisterableRoute.new('/path', type, 'app')
      expect(route).to_not be_valid
      expect(route).to have(1).error_on(:type)
    end
  end

  it 'validates path is absolute' do
    route = RegisterableRoute.new('not-absolute-path', 'exact', 'app')

    expect(route).to_not be_valid
    expect(route).to have(1).error_on(:path)
  end
end
