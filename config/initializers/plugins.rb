Dir[Rails.root.join('lib/plugins/*.rb')].each { |file| require file }

Plugins::Repository.install_plugins!(ENV.fetch('ACTIVE_PLUGIN_SET', '*'))
