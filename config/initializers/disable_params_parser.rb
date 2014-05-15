# We're doing our own JSON parsing, and error handling.
# If this is in place it causes 2 problems:
#
# Firstly, it pollutes the params hash with data from the json request, which
# leads to confusion when there is a param in the routes and in the json
#
# Secondly, when given invalid json, it blows up before even reaching the
# application, preventing us from handling invalid json gracefully.
Rails.application.config.middleware.delete "ActionDispatch::ParamsParser"
