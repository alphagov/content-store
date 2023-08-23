class ApplicationController < ActionController::API
  include GDS::SSO::ControllerMethods
  class InvalidRequest < RuntimeError; end

  before_action :authenticate_user!
  rescue_from Mongoid::Errors::DocumentNotFound, with: :error_404
  rescue_from InvalidRequest, with: :error_400

private

  def error_404
    head :not_found
  end

  def error_400
    head :bad_request
  end

  def config
    @config ||= ContentStore::Application.config
  end

  def parse_json_request
    # FIXME: base_path in the request body is deprecated and will be considered
    # an error once all clients have been updated.
    body = request.body.read
    @request_data = JSON.parse(body).except("base_path")
  rescue JSON::ParserError
    Rails.logger.warn "error parsing JSON from request body '#{body}'"
    head :bad_request
  end

  def encoded_request_path
    Addressable::URI.encode(request_path)
  rescue Addressable::URI::InvalidURIError
    Rails.logger.warn "Can't encode request_path '#{request_path}'"
    raise InvalidRequest
  end

  def encoded_base_path
    Addressable::URI.encode(base_path)
  rescue Addressable::URI::InvalidURIError
    Rails.logger.warn "Can't encode base_path '#{request_path}'"
    raise InvalidRequest
  end

  def request_path
    "/#{params[:path_without_root]}"
  end

  def base_path
    "/#{params[:base_path_without_root]}"
  end

  # The presenter needs context about routes and host names from controller
  # to know how to generate API URLs, so we can take the Rails helper and
  # pass that in as a callable
  def api_url_method
    if params[:public_api_request]
      method(:content_item_api_url)
    else
      method(:content_item_url)
    end
  end
end
