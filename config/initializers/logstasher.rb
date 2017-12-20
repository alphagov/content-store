if Object.const_defined?('LogStasher') && LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    fields[:govuk_dependency_resolution_source_content_id] = request.headers['GOVUK-Dependency-Resolution-Source-Content-Id']
  end
end
