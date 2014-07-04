require 'spec_helper'

describe RegisterableRedirect do
  it 'validates type is either "exact" or "prefix"' do
    %w(exact prefix).each do |type|
      route = build(:registerable_redirect, :type => type)
      expect(route).to be_valid
    end

    %w(invalid types).each do |type|
      route = build(:registerable_redirect, :type => type)
      expect(route).to_not be_valid
      expect(route).to have(1).error_on(:type)
    end
  end

  it 'validates path is absolute' do
    route = build(:registerable_redirect, :path => 'not-absolute-path')

    expect(route).to_not be_valid
    expect(route).to have(1).error_on(:path)
  end

  it 'validates destination is an absolute path' do
    route = build(:registerable_redirect, :destination => 'not-absolute-path')

    expect(route).to_not be_valid
    expect(route).to have(1).error_on(:destination)
  end
end
