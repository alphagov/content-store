if Object.const_defined?('LogStasher') && LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    # Mirrors Nginx request logging, e.g GET /path/here HTTP/1.1
    fields[:request] = "#{request.request_method} #{request.fullpath} #{request.headers['SERVER_PROTOCOL']}"
    # Pass request Id to logging
    fields[:govuk_request_id] = request.headers['GOVUK-Request-Id']
    fields[:govuk_dependency_resolution_source_content_id] = request.headers['GOVUK-Dependency-Resolution-Source-Content-Id']
  end
end
