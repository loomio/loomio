module Plugins
  class Fetcher
    attr_reader :folder, :repo, :branch

    def initialize(folder, config)
      @folder = folder.to_s.gsub('.', "").gsub('/', "")
      @repo   = config['repo'].to_s
      @branch = (config['branch'] || 'master').to_s
      @config = config.reject { |k| ['repo', 'branch'].include? k }
    end

    def execute!
      Dir.chdir(Rails.root) { `mkdir -p plugins/fetched` unless Dir.exists? 'plugins/fetched' }
      Dir.chdir(Rails.root.join('plugins','fetched'))  { fetch && set_config }
    rescue => e
      puts("WARNING: Unable to clone #{repo} at #{branch} into #{folder}: #{e.message}")
    end

    private

    def fetch
      # if exists pull else clone
      if Dir.exists? folder + "/.git"
        Dir.chdir(folder) {`git pull && git checkout #{branch}`}
      else
        `git clone -b #{branch} #{repo} #{folder}`
      end
    end

    def set_config
      return unless @config.present?
      Dir.chdir(@folder) do
        `touch config.yml`
        File.open('config.yml', 'a+') { |f| f.write @config.to_yaml.gsub('---', '') }
      end
    end
  end
end
