# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
# :hybrid reads both :marshal and :json formats but writes :json, which
# lets us migrate without invalidating existing sessions. After all active
# sessions have rotated (well beyond the session TTL), switch to :json.
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
