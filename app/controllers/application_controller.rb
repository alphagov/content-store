class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Mongoid::Errors::DocumentNotFound, :with => :error_404

  protected

  def error_404
    render :status => 404, :text => "Not found"
  end
end
