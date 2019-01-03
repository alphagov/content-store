class PublishIntentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :parse_json_request, only: [:update]

  def show
    intent = PublishIntent.find_by_path(encoded_request_path)

    return error_404 unless intent
    return redirect_canonical(intent) if intent.base_path != encoded_request_path

    render json: intent
  end

  def update
    result, intent = PublishIntent.create_or_update(encoded_base_path, @request_data)

    response_body = {}
    response_body[:errors] = intent.errors.as_json if intent.errors.any?
    render json: response_body, status: update_status(result)
  end

  def destroy
    intent = PublishIntent.find_by(base_path: encoded_base_path)
    intent.destroy

    render json: {}
  end

private

  def redirect_canonical(intent)
    route = publish_intent_url(intent.base_path_without_root)
    redirect_to route, status: 303
  end

  def update_status(result)
    return :unprocessable_entity unless result

    result == :created ? :created : :ok
  end
end
