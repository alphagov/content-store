class ContentItem
  include Mongoid::Document

  field :base_path, :type => String

  index({:base_path => 1}, {:unique => true})

  validates :base_path, :uniqueness => true
  validate :validate_base_path

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
