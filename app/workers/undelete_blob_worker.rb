class UndeleteBlobWorker
  include Sidekiq::Worker

  def perform(key)
    # client = Aws::S3::Client.new
    client = ActiveStorage::Blob.last.service.client.client

    resp = client.list_object_versions({bucket: "loomio-uploads", prefix: key})
    raise "wrong number of delete markers: #{key}, #{resp.delete_markers.count}" unless resp.delete_markers.count == 1

    resp.delete_markers.each do |marker|
      resp = client.delete_object({
        bucket: "loomio-uploads",
        key: key,
        version_id: marker.version_id
      })
    end
  end
end
