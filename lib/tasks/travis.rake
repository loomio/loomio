task :travis do
  run_commands "rspec spec", "cucumber"
  Dir.chdir "lineman"
  run_commands "lineman spec"
end

def run_commands(*commands)
  commands.each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end
