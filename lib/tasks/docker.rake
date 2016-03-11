# probably don't need this.
require_relative './run_commands'

namespace :docker do
  task :build do
    run_commands ['rm -rf tmp/*',
                  'git add lib/version',
                  'git commit -m "bump version"',
                  'git push origin master']
  end
end
