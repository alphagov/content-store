# When DISABLE_ROUTER_API is set to true, the application will use this
# class instead of GdsApi::Router
# This is to allow dual-running of both MongoDB and PostgreSQL Content Stores
# for a transition period during the migration to PostgreSQL
class MockRouterApi
  # Whatever the application tries to send to router-api,
  # just log it and do nothing else
  def method_missing(method_name, *args, **kwargs, &_block)
    log(method_name.to_s, args, kwargs)
  end

  def respond_to_missing?(method, *)
    GdsApi.router.methods.include?(method) || super
  end

private

  def log(method, *args, **kwargs)
    Rails.logger.info "Mocked call to router_api: #{method}(#{args}, #{kwargs})"
  end
end
