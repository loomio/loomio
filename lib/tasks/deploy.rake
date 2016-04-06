def run_commands(commands)
  commands.compact.each do |command|
    puts "\n-> #{command}"
    return false unless system(command)
  end
end

task :deploy do
  # usage script/deploy loomio-production master
  # usage:
  #   rake deploy:setup
  #   rake deploy                          # bump version, deploy master to loomio-production, run any migrations
  #
  #   rake deploy remote-name branch-name  # build, deploy, migrate with alternate remote and branch.
  #                                        # Eg: rake deploy loomio-clone master
  remote = ARGV[1] || 'loomio-production'
  branch = ARGV[2] || 'master'
  build_branch      = "deploy-#{remote}-#{branch}-#{Time.now.to_i}"

  puts "Deploying branch #{branch} to #{remote}..."
  run_commands [
    "git checkout #{branch}; git checkout -b #{build_branch}",                        # cut a new deploy branch based on specified branch
    "bundle exec rake deploy:build",                                                  # build assets
    "bundle exec rake deploy:commit",                                                 # add deploy commit
    ("bundle exec rake deploy:bump_version" if remote == 'loomio-production'),        # bump version if this is a production deploy
    "git push #{remote} #{build_branch}:master -f",                                   # DEPLOY!
    "git checkout #{branch}; git branch -D #{build_branch}",                          # switch back to original branch and delete deploy branch
    "bundle exec rake deploy:heroku_reset #{remote}"                                  # clean up heroku deploy
  ]
end

namespace :deploy do
  desc "Setup heroku and github for deployment"
  task :setup do
    remote = ARGV[1] || 'loomio-production'
    run_commands [
      "sh script/heroku_login.sh $DEPLOY_EMAIL $DEPLOY_PASSWORD",                       # login to heroku
      "echo \"Host heroku.com\n  StrictHostKeyChecking no\" > ~/.ssh/config",           # don't prompt for confirmation of heroku.com host
      "git config user.email $DEPLOY_EMAIL && git config user.name $DEPLOY_NAME",       # setup git commit user
      "git remote add #{remote} https://git.heroku.com/#{remote}.git"                   # add https heroku remote
    ]
  end

  desc "Builds assets for production push"
  task :build do
    plugins = ARGV[1] || 'loomio_org'
    puts "Building clientside assets, using plugin set #{plugins}..."
    run_commands [
      "rake 'plugins:acquire[#{plugins}]' plugins:resolve_dependencies",                # install plugins specified in plugins/plugins.yml
      "rm -rf plugins/**/.git",                                                         # allow cloned plugins to be added to this repo
      "cd angular && npm install && gulp compile && cd ../"                             # build the app via gulp
    ]
  end

  desc "Commits built assets to deployment branch"
  task :commit do
    puts "Committing assets to deployment branch..."
    run_commands [
      "cp -r public/client/development public/client/#{Loomio::Version.current}",       # version assets
      "find plugins -name '*.*' | xargs git add -f",                                    # add plugins folder to commit
      "git add public/client/#{Loomio::Version.current} public/client/fonts -f",        # add assets to commit
      "git commit -m 'Add compiled assets / plugin code'"                               # commit assets
    ]
  end

  desc "Bump version of repository if pushing to production"
  task :bump_version do
    puts "Bumping version from #{Loomio::Version.current}..."
    run_commands [
      "ruby script/bump_version patch",
      "git add lib/version",
      "git commit -m 'bump version'",
      "git push origin master"
    ]
    Loomio::Version.reload
  end

  desc "Migrate heroku database and restart dynos"
  task :heroku_reset do
    puts "Migrating & resetting heroku..."
    remote = ARGV[1]
    cmd    = `which heroku`.chomp

    run_commands [
      "#{cmd} run rake db:migrate -a #{remote}",
      "#{cmd} restart -a #{remote}",
      "#{cmd} run rake loomio:notify_clients_of_update -a #{remote}"
    ]
  end
end
