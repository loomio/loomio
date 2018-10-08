namespace :client do
  desc "Builds Loomio javascript client"
  task :build do
    puts "Building clientside assets..."
    run_commands(
      "cd client && node_modules/gulp/bin/gulp.js compile && cd ../",
      "rm -rf public/client/#{loomio_version}",
      "mv public/client/development public/client/#{loomio_version}")
  end
end
