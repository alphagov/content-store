require "rails_helper"

describe AbsolutePathValidator, type: :model do
  let(:validatable_path_class) do
    Struct.new(:path) do
      include ActiveModel::Validations
      validates :path, absolute_path: true
    end
  end

  context "with an absolute path" do
    subject { validatable_path_class.new("/absolute/path") }
    it { is_expected.to be_valid }
  end

  context "with a full URL" do
    subject { validatable_path_class.new("http://example.com/path") }
    it { is_expected.not_to be_valid }
  end

  context "with an invalid URL" do
    subject { validatable_path_class.new("not a path or a URL") }
    it { is_expected.not_to be_valid }
  end

  context "with a non-absolute path" do
    subject { validatable_path_class.new("relative/path") }
    it { is_expected.not_to be_valid }
  end

  context "with a path containing consecutive slashes" do
    subject { validatable_path_class.new("consecutive//slashes") }
    it { is_expected.not_to be_valid }
  end

  context "with a path containing trailing slashes" do
    subject { validatable_path_class.new("/trailing/slashes/") }
    it { is_expected.not_to be_valid }
  end
end
