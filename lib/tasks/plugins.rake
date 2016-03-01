namespace :plugins do
  task :acquire => :environment do
    `rm -rf #{[Rails.root, :plugins, :*, ''].join('/')}`
    require [Rails.root, :plugins, :"base.rb"].join('/')
    require [Rails.root, :plugins, :"fetcher.rb"].join('/')
    directory = YAML.load_file([Rails.root, :plugins, :"plugins.yml"].join('/'))['plugins']
    Dir.chdir('plugins') do
      directory.each { |plugin| Plugins::Fetcher.new(plugin[1]['repo'], plugin[1]['version'], plugin[1]['gemfile']).execute! }
    end
  end

  task :resolve_dependencies => :environment do
    `#{join_gemfiles} && bundle install && git add Gemfile Gemfile.lock -f`
  end

  def join_gemfiles
    "cat #{[Rails.root, :plugins, :Gemfile].join('/')} >> #{[Rails.root, :Gemfile].join('/')}"
  end
end
