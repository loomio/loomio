desc "Deploy to some git-remote and branch"
task :deploy do
  # usage script/deploy loomio-production master
  # usage:
  #   rake deploy                          # bump version, deploy master to loomio-production, run any migrations
  #
  #   rake deploy remote-name branch-name  # build, deploy, migrate with alternate remote and branch.
  #                                        # Eg: rake deploy loomio-clone master
  #

  def build_and_push_branch(remote, branch)
    build_branch = "deploy-#{remote}-#{branch}-#{Time.now.to_i}"
    run_commands ["git checkout #{branch}",
                  "git checkout -b #{build_branch}",
                  "cd lineman && npm install && bower install && lineman build",
                  "cp -R lineman/dist/* public/",
                  "cp lineman/vendor/bower_components/airbrake-js/airbrake-shim.js public/js/airbrake-shim.js",
                  "git add public/img public/css public/js public/fonts",
                  "git commit -m 'production build commit'",
                  "git checkout #{branch}",
                  "git push #{remote} #{build_branch}:master -f",
                  "git branch -D #{build_branch}"]
  end

  def heroku_migrate_and_restart(remote)
   run_commands ["ruby `which heroku` run rake db:migrate -a #{remote}",
                 "ruby `which heroku` restart -a #{remote}"]
  end

  def bump_version_and_push_origin_master
    run_commands ['ruby script/bump_version patch',
                  'git push origin master']
  end

  def run_commands(commands)
    commands.each do |command|
      puts "\n-> #{command}"
      return false unless system(command)
    end
  end

  remote = ARGV[1]
  branch = ARGV[2]

  if remote.blank?
    remote = 'loomio-production'
    branch = 'master'
    bump_version_and_push_origin_master
  end

  puts "building assets and deploying to #{remote}/#{branch}"
  build_and_push_branch(remote, branch) && heroku_migrate_and_restart(remote)

  exit 0
end
