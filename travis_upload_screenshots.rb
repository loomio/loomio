require 's3_uploader'
require 'date'

S3Uploader.upload_directory('/tmp/screenshots', 'loomio-travis2',
  { :s3_key => ENV['AWS_KEY'],
    :s3_secret => ENV['AWS_SECRET'],
    :destination_dir => "#{DateTime.now.strftime('%Y-%m-%d %H:%M')}-#{ENV['TRAVIS_PULL_REQUEST']}",
    :region => 'us-west-2',
    :threads => 4,
    :metadata => { 'Cache-Control' => 'max-age=315576000' }
    })
