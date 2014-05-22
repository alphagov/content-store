require 'spec_helper'

describe AbsolutePathValidator do
  class ValidatablePath < Struct.new(:path)
    include ActiveModel::Validations
    validates :path, absolute_path: true
  end

  context 'with an absolute path' do
    subject { ValidatablePath.new('/absolute/path') }
    it { should be_valid }
  end

  context 'with a full URL' do
    subject { ValidatablePath.new('http://example.com/path') }
    it { should_not be_valid }
  end

  context 'with an invalid URL' do
    subject { ValidatablePath.new('not a path or a URL') }
    it { should_not be_valid }
  end

  context 'with a non-absolute path' do
    subject { ValidatablePath.new('relative/path') }
    it { should_not be_valid }
  end

  context "with a path containing consecutive slashes" do
    subject { ValidatablePath.new('consecutive//slashes') }
    it { should_not be_valid }
  end

  context "with a path containing trailing slashes" do
    subject { ValidatablePath.new('/trailing/slashes/') }
    it { should_not be_valid }
  end
end
