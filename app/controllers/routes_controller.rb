class RoutesController < ApplicationController
  def find_route
    route = Route.find_matching_route(route_params[:path])

    if route
      render json: route_json(route)
    else
      render json: { error: "Route not found" }, status: :not_found
    end
  end

private

  def route_params
    params.permit(:path)
  end

  def route_json(route)
    {
      backend: route.backend,
      destination: route.destination,
      segments_mode: route.segments_mode,
      path: route.path,
      match_type: route.match_type,
    }
  end
end
