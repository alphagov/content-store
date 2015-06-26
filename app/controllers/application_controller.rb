class ApplicationController < ActionController::API

  rescue_from Mongoid::Errors::DocumentNotFound, :with => :error_404

  private

  def error_404
    head :not_found
  end

  def config
    @config ||= ContentStore::Application.config
  end

  def parse_json_request
    # FIXME base_path in the request body is deprecated and will be considered
    # an error once all clients have been updated.
    @request_data = JSON.parse(request.body.read).except('base_path')
  rescue JSON::ParserError
    head :bad_request
  end

  def encoded_base_path
    URI.escape(params[:base_path])
  end
end
