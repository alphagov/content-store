class RegisterableRedirect < RegisterableRoute
  def register!
    Rails.application.router_api.add_redirect_route(path, type, destination)
  end
end
