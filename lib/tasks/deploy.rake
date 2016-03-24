# define a DEPLOY_PATH, which is the location file, which defines a `Deploy` class containing
# a `push!` method, which is run to perform the deployment.
# the `push!` method will accept the array of arguments passed to the rake task

desc "Deploy to some git-remote and branch"
task :deploy do
  load ENV['DEPLOY_PATH']
  Deploy.push!(*ARGV)
  exit 0
end
