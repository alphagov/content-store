class RegisterableRoute < OpenStruct
  def register!(rendering_app)
    Rails.application.router_api.add_route(path, type, rendering_app)
  end
end
