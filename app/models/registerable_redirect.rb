class RegisterableRedirect < OpenStruct
  include ActiveModel::Validations

  validates :type, inclusion: { in: %w(exact prefix), message: 'must be either "exact" or "prefix"' }
  validates :path, :destination, absolute_path: true
  validates :path, :type, :destination, presence: true
end
