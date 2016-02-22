require [Rails.root, :plugins, :base].join('/')
Plugins::Repository.install_plugins!
