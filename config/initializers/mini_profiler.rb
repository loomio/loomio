Rack::MiniProfiler.config.skip_paths << '/admin'
Rack::MiniProfiler.config.use_existing_jquery = false
Rack::MiniProfiler.config.pre_authorize_cb = lambda {|env| false}
