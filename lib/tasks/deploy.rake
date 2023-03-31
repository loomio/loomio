def deploy_steps
  [
    "deploy:fetch",
    "deploy:commit",
    "deploy:push",
    "deploy:cleanup"
  ].join(' ')
end

namespace :deploy do
  desc "Deploy to heroku"
  task :heroku do
    puts "Deploying to #{heroku_remote}..."
    run_commands("bundle exec rake #{deploy_steps}")
    at_exit { run_commands("git branch -D #{deploy_branch}") }
  end

  desc "fetch additional stuff"
  task :fetch do
    ['engines/loomio_subs','loomio-website'].each do |dir|
      run_commands("rm -rf #{dir}") if Dir.exists?(dir)
    end

    puts "fetching loomio_subs"
    run_commands("git clone -b main git@github.com:loomio/loomio_subs.git engines/loomio_subs")
    puts "fetch loomio-website"
    run_commands("git clone -b main git@github.com:loomio/loomio-website.git loomio-website")
    Dir.chdir("loomio-website") do
      run_commands("npm install")
      run_commands("npm run build")
    end
    run_commands("cp -R ./loomio-website/_site/* ./public/")
    run_commands("rm -rf loomio-website")
  end

  desc "Commits built assets to deployment branch"
  task :commit do
    puts "Committing assets to deployment branch..."
    run_commands(
      "git checkout -b #{deploy_branch}",
      "rm -rf engines/**/.git",
      "git add -f engines",
      "git add -f public",
      "git commit -m 'Add marketing plugin only'",
      "git checkout master")
  end

  desc "Push to heroku!"
  task :push, [:remote,:branch,:id] do |t, args|
    puts "Deploying #{deploy_branch} to heroku remote #{heroku_remote}"
    run_commands("git push #{heroku_remote} #{deploy_branch}:master -f")
  end

  desc "Migrate heroku database and restart dynos"
  task :cleanup do
    puts "Migrating heroku..."
    run_commands(
      "#{heroku_cli} run rake db:migrate -a #{heroku_remote}",
      "#{heroku_cli} restart -a #{heroku_remote}"
    )
  end
end

task :deploy => :"deploy:heroku"

def loomio_version
  Loomio::Version.current
end

def deploy_branch
  @deploy_branch ||= "deploy-#{Time.now.to_i}"
end

def heroku_cli
  @heroku_cli ||= `which heroku`.chomp
end

def heroku_remote
  ENV.fetch('HEROKU_REMOTE', 'loomio-production')
end

def run_commands(*commands)
  Array(commands).compact.each do |command|
    puts "\n-> #{command}"
    raise "command failed: #{command}" unless system(command)
  end
end
