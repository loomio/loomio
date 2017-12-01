require Rails.root.join(*%w(lib plugins base))
require Rails.root.join(*%w(lib plugins fetcher))

namespace :plugins do

  task :fetch, [:plugin_set] do |t, args|
    plugin_set = args[:plugin_set] || 'plugins'
    return unless yaml = YAML.load_file(Rails.root.join(*['config', plugin_set + '.yml']))
    yaml.each_pair { |name, config| Plugins::Fetcher.new(name, config).execute! }
  end

  task :install => :environment do
    require Rails.root.join(*%w(lib plugins base))
    Plugins::Repository.install_plugins!
  end
end
