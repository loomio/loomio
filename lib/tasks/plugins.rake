Dir[Rails.root.join('lib/plugins/*.rb')].each { |file| require file }

namespace :plugins do

  task :fetch, [:plugin_set] do |t, args|
    plugin_set = args[:plugin_set] || 'loomio_org'
    return unless yaml = YAML.load_file(Rails.root.join(*['config', "plugins.#{plugin_set}.yml"]))
    yaml.each_pair { |name, config| Plugins::Fetcher.new(name, config).execute! }
  end

  task :install, [:plugin_set] do |t, args|
    plugin_set = args[:plugin_set] || '*'
    Plugins::Repository.install_plugins!(plugin_set)
  end
end
