# The Ruby server under Puma, without Rails, for benchmarking:
#   bundle exec puma -t 5:5 -b tcp://127.0.0.1:4601 lib/collab_server/bench/ruby_server.ru
# Set STACKPROF=path to write a CPU profile when Puma stops.
require_relative "../../collab_server"

CollabServer.configure do |config|
  config.timeout = 30
  config.threads = Integer(ENV.fetch("THREADS", 4))
end

if (path = ENV["STACKPROF"])
  require "stackprof"
  StackProf.start(mode: (ENV["STACKPROF_MODE"] || "cpu").to_sym, interval: ENV["STACKPROF_MODE"] == "object" ? 1 : 1000, raw: true)
  at_exit do
    StackProf.stop
    StackProf.results(path)
  end
end

run CollabServer.server
