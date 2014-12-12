class RegisterableRedirect < RegisterableRoute

  validates :destination, presence: true, absolute_path: true

  def register!
    Rails.application.router_api.add_redirect_route(path, type, destination)
  end
end
