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
# rake deploy:build        -- acquire plugins and build all clientside assets
# rake deploy:commit       -- commit all non-repository code to a branch for pushing
# rake deploy:push         -- push deploy branch to heroku
# rake deploy:bump_version -- add a commit to master which bumps the current version (when deploying to loomio-production only)
# rake deploy:heroku_reset -- run rake db:migrate on heroku, restart dynos, and notify clients of version update

task :deploy do
  remote, branch = ARGV[1] || 'loomio-production', ARGV[2] || 'master'
  is_production_push = remote == 'loomio-production' && branch == 'master'
  id = Time.now.to_i
  temp_branch = build_branch(remote, branch, id)

  puts "Deploying branch #{branch} to #{remote}..."
  run_commands [
    "git checkout #{branch}",                                                         # move to specified deploy branch
    "git checkout -b #{temp_branch}",                                                 # cut a new deploy branch based on specified branch
    "bundle exec rake deploy:bump_version[#{temp_branch},#{is_production_push}]",     # bump version if this is a production deploy
    "bundle exec rake deploy:build",                                                  # build assets
    "bundle exec rake deploy:commit",                                                 # add deploy commit
    "bundle exec rake deploy:push[#{remote},#{branch},#{id}]",                        # deploy to heroku
    "bundle exec rake deploy:heroku_reset[#{remote}]"                                 # clean up heroku deploy
  ]
  at_exit     { cleanup(remote, branch, id) }
end

def cleanup(remote, branch, id)
  run_commands ["git checkout #{branch}; git branch -D #{build_branch(remote, branch, id)}"]
end

namespace :deploy do
  desc "Setup heroku and github for deployment"
  task :setup do
    remote = ARGV[1] || 'loomio-production'
    run_commands [
      "sh script/heroku_login.sh $DEPLOY_EMAIL $DEPLOY_PASSWORD",                     # login to heroku
      "echo \"Host heroku.com\n  StrictHostKeyChecking no\" > ~/.ssh/config",         # don't prompt for confirmation of heroku.com host
      "git config user.email $DEPLOY_EMAIL && git config user.name $DEPLOY_NAME",     # setup git commit user
      "git remote add #{remote} https://git.heroku.com/#{remote}.git"                 # add https heroku remote
    ]
  end

  desc "Builds assets for production push"
  task :build, [:plugin_set] do |t, args|
    plugin_set = args[:plugin_set] || :plugins
    puts "Building clientside assets, using plugin set #{plugin_set}..."
    run_commands [
      "rake 'plugins:fetch[#{plugin_set}]' plugins:install",                             # install plugins specified in plugins/plugins.yml
      "rm -rf plugins/**/.git",                                                          # allow cloned plugins to be added to this repo
      "cd angular && yarn && node_modules/gulp/bin/gulp.js compile && cd ../",    # build the app via gulp
      "cp -r public/client/development public/client/#{Loomio::Version.current}"         # version assets
    ]
  end

  desc "Commits built assets to deployment branch"
  task :commit do
    puts "Committing assets to deployment branch..."
    run_commands [
      "find plugins -name '*.*' | xargs git add -f",                                  # add plugins folder to commit
      "git add public/client/#{Loomio::Version.current} public/client/fonts -f",      # add assets to commit
      "git commit -m 'Add compiled assets / plugin code'"                             # commit assets
    ]
  end

  desc "Bump version of repository if pushing to production"
  task :bump_version, [:branch, :is_production_push] do |t, args|
    raise 'branch must be specified' unless branch = args[:branch]
    is_production_push = args[:is_production_push] == 'true'

    puts "Bumping version from #{Loomio::Version.current}..."
    run_commands [
      "ruby script/bump_version.rb #{is_production_push ? 'patch' : 'test'}",
      "git add lib/version",
      "git commit -m 'bump version to #{Loomio::Version.current}'",
     ("git push origin #{branch}:master" if is_production_push)
    ]
  end

  desc "Push to heroku!"
  task :push, [:remote,:branch,:id] do |t, args|
    raise 'remote must be specified' unless remote = args[:remote]
    raise 'branch must be specified' unless branch = args[:branch]
    raise 'deploy branch id must be specified' unless id = args[:id]

    puts "Deploying #{build_branch(remote, branch, id)} to heroku remote #{remote}"
    run_commands [
      "git push #{remote} #{build_branch(remote, branch, id)}:master -f",                 # DEPLOY!
    ]
  end

  desc "Migrate heroku database and restart dynos"
  task :heroku_reset, [:remote] do |t, args|
    puts "Migrating & resetting heroku..."
    raise 'remote must be specified!' unless remote = args[:remote]
    cmd = `which heroku`.chomp

    run_commands [
      "#{cmd} run rake db:migrate -a #{remote}",                                      # Migrate Heroku DB
      "#{cmd} restart -a #{remote}",                                                  # Restart Heroku dynos
      "#{cmd} run -a #{remote} rake loomio:notify_clients_of_update"                  # Notify clients of update
    ]
  end
end

def build_branch(remote, branch, id)
  "deploy-#{remote}-#{branch}-#{id}"
end

def run_commands(commands)
  commands.compact.each do |command|
    puts "\n-> #{command}"
    return false unless system(command)
  end
end
