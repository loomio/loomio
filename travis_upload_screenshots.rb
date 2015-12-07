require 's3_uploader'

S3Uploader.upload_directory('/tmp/screenshots', 'loomio-travis2',
  { :s3_key => ENV['AWS_KEY'],
    :s3_secret => ENV['AWS_SECRET'],
    :destination_dir => "test2#{ENV['TRAVIS_BRANCH']}",
    :region => 'us-west-2',
    :threads => 4,
    :metadata => { 'Cache-Control' => 'max-age=315576000' }
    })
