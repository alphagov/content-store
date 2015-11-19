require 'taggings_per_app'

class DebugController < ApplicationController
  def taggings_per_app
    render json: TaggingsPerApp.new(params.fetch(:app)).taggings
  end
end
