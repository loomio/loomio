require [Rails.root, :lib, :plugins, :base].join('/')
Plugins::Repository.install_plugins!
