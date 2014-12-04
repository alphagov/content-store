class PublishIntentsController < ApplicationController
  before_filter :parse_json_request, :only => [:update]

  def show
    intent = PublishIntent.find_by(:base_path => encoded_base_path)

    render :json => intent
  end

  def update
    intent = PublishIntent.find_or_initialize_by(:base_path => encoded_base_path)
    status_to_use = intent.new_record? ? :created : :ok
    intent.update_attributes(@request_data) or status_to_use = :unprocessable_entity

    render :json => intent, :status => status_to_use
  end

  def destroy
    intent = PublishIntent.find_by(:base_path => encoded_base_path)
    intent.destroy

    render :json => intent
  end
end
