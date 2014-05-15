class ContentItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :base_path, :type => String
  field :title, :type => String
  field :description, :type => String
  field :format, :type => String
  field :need_ids, :type => Array, :default => []
  field :public_updated_at, :type => DateTime
  field :details, :type => Hash, :default => {}

  index({:base_path => 1}, {:unique => true})

  attr_protected :base_path

  validates :base_path, :uniqueness => true
  validate :validate_base_path
  validates :title, :format, :presence => true

  def as_json(options = nil)
    super.except('_id', 'updated_at', 'created_at').tap do |hash|
      hash["errors"] = self.errors.as_json.stringify_keys if self.errors.any?
    end
  end

  private

  def validate_base_path
    unless valid_absolute_url_path?(self.base_path)
      errors[:base_path] << "is not a valid absolute URL path"
    end
  end

  def valid_absolute_url_path?(path)
    return false unless path.present? and path.starts_with?("/")
    uri = URI.parse(path)
    uri.path == path && path !~ %r{//} && path !~ %r{./\z}
  rescue URI::InvalidURIError
    false
  end
end
