namespace :client do
  desc "Builds Loomio javascript client"
  task :build do
    puts "Building clientside assets..."
    run_commands(
      "rm -rf public/client/*",
      "cd client && npm i && node_modules/gulp/bin/gulp.js compile && cd ..",
      "mv public/client/development public/client/#{loomio_version}")
  end
end
