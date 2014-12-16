class RegisterableRoute < OpenStruct
  include ActiveModel::Validations

  validates :type, inclusion: { in: %w(exact prefix), message: 'must be either "exact" or "prefix"' }
  validates :path, absolute_path: true
  validates :path, :type, presence: true

  def register!(rendering_app)
    Rails.application.router_api.add_route(path, type, rendering_app)
  end

  def exact?
    type == "exact"
  end
end
