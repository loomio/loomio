class Metadata::UserSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def title
    object.name
  end

  def description
    render_plain_text(object.short_bio, object.short_bio_format)
  end

  def image_urls
    [object.avatar_url(:large)]
  end
end
