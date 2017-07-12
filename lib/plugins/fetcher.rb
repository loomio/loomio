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
      Dir.chdir(Rails.root.join('fetched_plugins')) do
        clean && fetch && set_config
      end
      Dir.chdir(Rails.root) do
        link
      end
    rescue => e
      puts("WARNING: Unable to clone #{repo} at #{branch} into #{folder}: #{e.message}")
    end

    private
    def link
      `rm plugins; ln -s fetched_plugins plugins`
    end

    def clean
      return true unless Dir.exists?(folder)
      `rm -rf #{folder}`
    end

    def fetch
      `git clone -b #{branch} #{repo} #{folder}`
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
