# Collaborative editing server (lib/hocuspocus), mounted at /hocuspocus. It
# relays Yjs documents between the browsers editing a record; saved records
# hold the content, so documents only live in memory while someone is
# connected.
#
# Clients are identified by their session cookie, so only pages from this host
# may connect: browsers attach cookies to WebSocket requests from any site.
require Rails.root.join('lib/hocuspocus').to_s

Hocuspocus.configure do |config|
  config.logger = Rails.logger
  config.wrapper = ->(&block) { Rails.application.executor.wrap(&block) }
  config.error_handler = ->(error, context) { Rails.error.report(error, context: context, handled: true) }

  config.allowed_origin = lambda do |origin|
    host = URI.parse(origin.to_s).host
    host.present? && (host == ENV['CANONICAL_HOST'] || (!Rails.env.production? && host == 'localhost'))
  rescue URI::InvalidURIError
    false
  end

  config.authenticate = lambda do |document_name:, env:|
    user = CollabDocumentAuthService.user_from_session(env)
    CollabDocumentAuthService.authorized?(user: user, document_name: document_name)
  end
end

Rails.application.config.after_initialize do
  Hocuspocus.config.pubsub = ActionCable.server.pubsub
end
