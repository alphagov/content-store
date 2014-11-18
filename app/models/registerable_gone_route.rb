class RegisterableGoneRoute < RegisterableRoute
  def register!
    Rails.application.router_api.add_gone_route(path, type)
  end
end
