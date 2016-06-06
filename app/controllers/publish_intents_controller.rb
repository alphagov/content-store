class PublishIntentsController < ApplicationController
  before_filter :parse_json_request, only: [:update]

  def show
    intent = PublishIntent.find_by(base_path: encoded_base_path)

    render json: intent
  end

  def update
    result, intent = PublishIntent.create_or_update(encoded_base_path, @request_data)

    status = status_from_result(result)

    response_body = {}
    response_body[:errors] = intent.errors.as_json if intent.errors.any?
    render json: response_body, status: status
  end

  def destroy
    intent = PublishIntent.find_by(base_path: encoded_base_path)
    intent.destroy

    render json: {}
  end

private

  def status_from_result(result)
    case result
    when false
      :unprocessable_entity
    when :created
      :created
    else
      :ok
    end
  end
end
