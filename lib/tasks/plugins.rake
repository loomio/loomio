require Rails.root.join(*%w(lib plugins base))
require Rails.root.join(*%w(lib plugins fetcher))

namespace :plugins do
  def yaml
    @yaml ||= YAML.load_file(Rails.root.join(*%w(config plugins.yml)))
  end

  task fetch: :environment do
    return unless yaml
    yaml.each_pair do |name, config|
      Plugins::Fetcher.new(name, config['repo'], config['branch']).execute!
    end
  end

  task :install => :environment do
    require Rails.root.join(*%w(lib plugins base))
    Plugins::Repository.install_plugins!
  end
end
