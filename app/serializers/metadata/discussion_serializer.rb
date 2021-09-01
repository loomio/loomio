class Metadata::DiscussionSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def description
    render_plain_text(object.description, object.description_format)
  end

  def image_urls
    [object.group.cover_url, object.group.logo_url]
  end
end
