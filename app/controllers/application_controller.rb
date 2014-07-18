class ApplicationController < ActionController::API

  rescue_from Mongoid::Errors::DocumentNotFound, :with => :error_404

  private

  def error_404
    head :not_found
  end

  def expires_at(expiration_time)
    response.headers['Cache-Control'] = config.cache_control_directive
    response.headers['Expires'] = expiration_time.httpdate
  end

  def config
    @config ||= ContentStore::Application.config
  end
end
