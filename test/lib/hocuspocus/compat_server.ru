# Ruby Hocuspocus server for provider_compat.test.mjs:
#   bundle exec puma -q -b tcp://127.0.0.1:4700 test/lib/hocuspocus/compat_server.ru
# Documents named denied-* are refused; private-* need the cookie session=ok,
# as Loomio identifies users by their session cookie.
require_relative "../../../lib/hocuspocus"

Hocuspocus.configure do |config|
  config.authenticate = lambda do |document_name:, env:|
    next false if document_name.start_with?("denied")
    next env["HTTP_COOKIE"].to_s.include?("session=ok") if document_name.start_with?("private")

    true
  end
end

map("/control/stop") { run ->(_env) { Hocuspocus.server.stop; [200, {}, ["stopped"]] } }
map("/control/start") { run ->(_env) { Hocuspocus.server.start; [200, {}, ["started"]] } }
run Hocuspocus.server
