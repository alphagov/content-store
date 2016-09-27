class PublishIntentsController < ApplicationController
  before_action :parse_json_request, only: [:update]

  def show
    intent = PublishIntent.find_by(base_path: encoded_base_path)

    render json: intent
  end

  def update
    result, intent = PublishIntent.create_or_update(encoded_base_path, @request_data)

    if result
      status = (result == :created ? :created : :ok)
    else
      status = :unprocessable_entity
    end
    response_body = {}
    response_body[:errors] = intent.errors.as_json if intent.errors.any?
    render json: response_body, status: status
  end

  def destroy
    intent = PublishIntent.find_by(base_path: encoded_base_path)
    intent.destroy

    render json: {}
  end
end
