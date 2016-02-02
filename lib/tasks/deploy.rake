def run_commands(commands)
  commands.each do |command|
    puts "\n-> #{command}"
    return false unless system(command)
  end
end

def bump_version_and_push_origin_master
  puts "updating loomio-production version and committing to github..."
  run_commands ['ruby script/bump_version patch',
                'git add lib/version',
                'git commit -m "bump version"',
                'git push origin master']
  Loomio::Version.reload
end

def setup_heroku
  puts "setup heroku"
  run_commands ["sh script/heroku_login.sh $DEPLOY_EMAIL $DEPLOY_PASSWORD",                       # login to heroku
                "echo \"Host heroku.com\n  StrictHostKeyChecking no\" > ~/.ssh/config"]           # don't prompt for confirmation of heroku.com host
end

def setup_git_remote(remote)
  puts "setup git remote #{remote}"
  run_commands ["git config user.email $DEPLOY_EMAIL && git config user.name $DEPLOY_NAME",       # setup git commit user
                "git remote add #{remote} https://git.heroku.com/#{remote}.git"]                  # add https heroku remote

end

def build_and_push_branch(remote, branch)
  puts "building assets and deploying to #{remote}/#{branch}..."
  build_branch = "deploy-#{remote}-#{branch}-#{Time.now.to_i}"
  run_commands ["git checkout #{branch}",                                                         # checkout branch
                "git checkout -b #{build_branch}",                                                # cut a new deploy branch off of that branch
                "cd angular && npm install && gulp compile && cd ../",                            # build the app via gulp
                "cp -r public/assets public/assets-#{Loomio::Version.current}",                   # version assets
                "git add public/assets public/assets-#{Loomio::Version.current} public/fonts -f", # add assets to commit
                "git commit -m 'Add assets for production push'",                                 # commit assets
                "git push #{remote} #{build_branch}:master -f",                                   # DEPLOY!
                "git checkout #{branch}",                                                         # switch back to original branch
                "git branch -D #{build_branch}"]                                                  # delete production branch
end

def heroku_migrate_and_restart(remote)
  puts "migrating and restarting heroku app #{remote}..."
  run_commands ["ruby /usr/local/heroku/bin/heroku run rake db:migrate -a #{remote}",
                "ruby /usr/local/heroku/bin/heroku restart -a #{remote}",
                "ruby /usr/local/heroku/bin/heroku run rake loomio:notify_clients_of_update -a #{remote}"]
end

desc "Deploy to some git-remote and branch"
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

  (remote != 'loomio-production' || bump_version_and_push_origin_master) &&
  build_and_push_branch(remote, branch) &&
  heroku_migrate_and_restart(remote)

  exit 0
end

namespace :deploy do
  task :with_setup do
    remote = ARGV[1] || 'loomio-production'
    branch = ARGV[2] || 'master'

    setup_heroku
    setup_git_remote(remote)

    (remote != 'loomio-production' || bump_version_and_push_origin_master) &&
    build_and_push_branch(remote, branch) &&
    heroku_migrate_and_restart(remote)

    exit 0
  end
end
