namespace :deploy do
  task :fetch do
    ['engines/loomio_subs','loomio-website'].each do |dir|
      run_commands("rm -rf #{dir}") if Dir.exist?(dir)
    end

    puts "fetching loomio_subs"
    run_commands("git clone --branch main --depth 1 git@github.com:loomio/loomio_subs.git engines/loomio_subs")
    puts "fetch loomio-website"
    run_commands("git clone --branch main --depth 1 git@github.com:loomio/loomio-website.git loomio-website")
    Dir.chdir("loomio-website") do
      run_commands("npm install")
      run_commands("npm run build")
    end
    run_commands("cp -R ./loomio-website/_site/* ./public/")
    run_commands("rm -rf loomio-website")
    run_commands("rm -rf engines/**/.git")
  end
end

def run_commands(*commands)
  Array(commands).compact.each do |command|
    puts "\n-> #{command}"
    raise "command failed: #{command}" unless system(command)
  end
end
