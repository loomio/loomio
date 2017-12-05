# DEPLOYING LOOMIO
# To run a full deploy simply run
# `rake deploy`
#
# This will push the current master branch to production.
# You can also specify the heroku remote, and the branch to be deployed, like so:
# `rake deploy <remote> <branch>`
#
# So, running `rake deploy loomio-clone test-feature` will deploy the test-feature branch
# to the heroku remote named loomio-clone
#
# This script is also modular, meaning you can run any part of it individually.
# The order of operations goes:
#
# rake deploy:bump_version    -- add a commit to master which bumps the current version
# rake deploy:plugins:fetch   -- fetch plugins from the loomio_org plugins.yml
# rake deploy:plugins:install -- install plugins so the correct files are built and deployed
# rake deploy:build           -- build all clientside assets
# rake deploy:commit          -- commit all non-repository code to a branch for pushing
# rake deploy:push            -- push deploy branch to heroku
# rake deploy:cleanup         -- run rake db:migrate on heroku, restart dynos, and notify clients of version update

namespace :deploy do
  desc "Deploy to heroku"
  task :heroku do
    puts "Deploying to #{heroku_remote}..."
    run_commands(
      "git checkout master",
      "git checkout -b deploy-#{Time.now.to_i}",
      "bundle exec rake
        plugins:fetch[loomio_org]
        plugins:install[#{heroku_plugin_set}]
        plugins:merge_repo
        deploy:build
        deploy:commit
        deploy:cleanup")
    at_exit do
      run_commands("git checkout master", "git branch -D #{deploy_branch_name}")
    end
  end

  desc "Setup heroku and github for deployment"
  task :setup do
    puts "Logging into heroku and setting up remote..."
    run_commands(
      "sh script/heroku_login.sh $DEPLOY_EMAIL $DEPLOY_PASSWORD",
      "echo \"Host heroku.com\n  StrictHostKeyChecking no\" > ~/.ssh/config",
      "git config user.email $DEPLOY_EMAIL && git config user.name $DEPLOY_NAME",
      "git remote add #{remote} https://git.heroku.com/#{heroku_remote}.git")
  end

  desc "Builds assets for production push"
  task :build do
    puts "Building clientside assets..."
    run_commands(
      "cd angular && yarn && node_modules/gulp/bin/gulp.js compile && cd ../",
      "mkdir -p public/client/#{Loomio::Version.current}",
      "cp -r public/client/development/* public/client/#{Loomio::Version.current}")
  end

  desc "Commits built assets to deployment branch"
  task :commit do
    puts "Committing assets to deployment branch..."
    run_commands(
      "rm -rf plugins/fetched/**/.git",
      "find plugins/fetched -name '*.*' | xargs git add -f",
      "find public/img/emojis -name '*.png' | xargs git add -f",
      "git add -f plugins",
      "git add public/client/#{Loomio::Version.current} public/client/fonts -f",
      "git commit -m 'Add compiled assets / plugin code'")
  end

  desc "Bump version of repository if pushing to production"
  task :bump_version do
    puts "Bumping version from #{Loomio::Version.current}..."
    run_commands(
      "ruby script/bump_version.rb patch",
      "git add lib/version",
      "git commit -m 'bump version to #{Loomio::Version.current}'",
      "git push origin #{build_branch}:master")
  end

  desc "Push to heroku!"
  task :push, [:remote,:branch,:id] do |t, args|
    puts "Deploying #{build_branch} to heroku remote #{heroku_remote}"
    run_commands("git push #{heroku_remote} #{build_branch}:master -f")
  end

  desc "Migrate heroku database and restart dynos"
  task :cleanup do
    puts "Migrating & resetting heroku..."
    run_commands(
      "#{heroku_cli} run rake db:migrate -a #{heroku_remote}",
      "#{heroku_cli} restart -a #{heroku_remote}")
  end
end

task :deploy => :"deploy:heroku"

def build_branch
  @build_branch ||= `git rev-parse --abbrev-ref HEAD`.chomp
end

def heroku_cli
  @heroku_cli ||= `which heroku`.chomp
end

def heroku_plugin_set
  ENV.fetch('HEROKU_PLUGIN_SET', 'loomio_org')
end

def heroku_remote
  ENV.fetch('HEROKU_REMOTE', 'loomio-production')
end

def run_commands(*commands)
  Array(commands).compact.each do |command|
    puts "\n-> #{command}"
    return false unless system(command)
  end
end
