module Plugins
  class Fetcher
    attr_reader :folder, :repo, :branch

    def initialize(folder, repo, branch)
      @folder = folder.to_s.gsub('.', "").gsub('/', "")
      @repo = repo.to_s
      @branch = (branch || 'master').to_s
    end

    def execute!
      Dir.chdir(Rails.root.join('plugins')) do
        clean && fetch
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
  end
end
