module Plugins
  class Fetcher
    attr_reader :folder, :repo, :branch

    def initialize(folder, config)
      @folder = folder.to_s.gsub('.', "").gsub('/', "")
      @repo   = config['repo'].to_s
      @branch = (config['version'] || 'master').to_s
      @config = config.reject { |k| ['repo', 'version'].include? k }
    end

    def execute!
      Dir.chdir(Rails.root.join('plugins')) do
        clean && fetch && set_config
      end
    rescue => e
      puts("WARNING: Unable to clone #{repo} at #{branch} into #{folder}: #{e.message}")
    end

    private

    def clean
      `rm -rf #{folder}`
    end

    def fetch
      `git clone -b #{branch} git://github.com/#{repo} #{folder}`
    end

    def set_config
      Dir.chdir(@folder) do
        File.open('config.yml', 'w') { |f| f.write @config.to_yaml }
      end
    end
  end
end
