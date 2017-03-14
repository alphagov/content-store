class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :error_404

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

  def encoded_request_path
    URI.escape(request_path)
  end

  def encoded_base_path
    URI.escape(base_path)
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
