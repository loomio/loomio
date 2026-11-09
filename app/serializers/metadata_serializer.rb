class MetadataSerializer < ActiveModel::Serializer
  root false

  private

  # Link previews need a readable excerpt, without section headings or joined paragraphs.
  def description_excerpt(text, format)
    MarkdownService.render_excerpt(text, format)
  end

  # Link preview services fetch images from the page's host, so send absolute URLs.
  def absolute_image_urls(*paths)
    root = Rails.application.routes.url_helpers.root_url(ActionMailer::Base.default_url_options)
    paths.compact.map { |path| URI.join(root, path).to_s }
  end
end
