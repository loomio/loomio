Rack::MiniProfiler.config.skip_paths << '/admin'
Rack::MiniProfiler.config.use_existing_jquery = true
Rack::MiniProfiler.config.pre_authorize_cb = lambda {|env| Rails.env.development?}
