class ApplicationController < ActionController::API

  rescue_from Mongoid::Errors::DocumentNotFound, :with => :error_404

  private

  def error_404
    head :not_found
  end
end
