module Plugins
  Fetcher = Struct.new(:repo, :version, :gems, :force) do

    def execute!
      fetch && checkout && bundle if should_execute?
    rescue => e
      clean && puts("WARNING: Unable to clone #{repo} at #{version}: #{e.message}")
    end

    private

    def should_execute?
      clean if force
      !File.directory?(folder)
    end

    def clean
      SafeShell.execute "rm", "-rf", folder
    end

    def fetch
      puts "cloning #{repo}..."
      SafeShell.execute "git", "clone", "git@github.com:#{repo}.git"
    end

    def checkout
      puts "checking out #{version}..."
      Dir.chdir(folder) { SafeShell.execute "git", "checkout", version || "master" }
    end

    def folder
      @folder ||= repo.split('/').last
    end
  end
end
