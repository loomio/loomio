require 's3_uploader'
require 'date'

destination_dir = "#{DateTime.now.strftime('%Y%m%d_%H%M')}-#{ENV['TRAVIS_PULL_REQUEST']}"
S3Uploader.upload_directory('angular/test/protractor/screenshots/', 'loomio-travis2',
  { :s3_key => ENV['AWS_KEY'],
    :s3_secret => ENV['AWS_SECRET'],
    :destination_dir => destination_dir,
    :region => 'us-west-2',
    :threads => 4,
    :public => true,
    :metadata => { 'Cache-Control' => 'max-age=315576000' }
    })

puts "report available at https://s3-us-west-2.amazonaws.com/loomio-travis2/#{destination_dir}/index.html"
