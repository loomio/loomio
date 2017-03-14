require 's3_uploader'
require 'date'

destination_dir = "#{DateTime.now.strftime('%Y%m%d_%H%M')}-#{ENV['TRAVIS_PULL_REQUEST']}"
p ENV['ARTIFACTS_BUCKET'], ENV['ARTIFACTS_KEY'],ENV['ARTIFACTS_SECRET']

S3Uploader.upload_directory('angular/screenshots/', ENV['ARTIFACTS_BUCKET'],
  { :s3_key => ENV['ARTIFACTS_KEY'],
    :s3_secret => ENV['ARTIFACTS_SECRET'],
    :destination_dir => destination_dir,
    :region => 'us-east-1',
    :threads => 4,
    :public => true,
    :metadata => { 'Cache-Control' => 'max-age=315576000' }
    })

puts "report available at https://s3-us-east-1.amazonaws.com/loomio-travis2/#{destination_dir}/index.html"
