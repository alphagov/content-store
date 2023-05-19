# When DISABLE_ROUTER_API is set to true, the application will use this
# class instead of GdsApi::Router
# This is to allow dual-running of both MongoDB and PostgreSQL Content Stores
# for a transition period during the migration to PostgreSQL
class MockRouterApi
  def delete_route(*args)
    log("delete_route", args)
  end

  def add_backend(*args)
    log "add_backend", args
  end

  def add_redirect_route(*args)
    log "add_redirect_route", args
  end

  def add_gone_route(*args)
    log "add_gone_route", args
  end

  def add_route(*args)
    log "add_route", args
  end

  def commit_routes(*args)
    log "commit_routes", args
  end

private

  def log(method, args)
    logger.debug "Mocked call to router_api: #{method}(#{args})"
  end
end
