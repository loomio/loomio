# frozen_string_literal: true

class Views::EventMailer::Common::Attachments < Views::BaseMailer::Base

  def initialize(resource:)
    @resource = resource
  end

  def view_template
    div(class: "max-width-600") do
      render_link_previews if @resource.link_previews.any?
      render_file_attachments if @resource.attachments.any?
    end
  end

  private

  def render_link_previews
    h4(class: "text-subtitle-2") { plain t(:'common.links') }
    ul(class: "thread-mailer__list") do
      @resource.link_previews.each do |preview|
        div(style: "border: 1px solid #eee; border-radius: 4px; margin-bottom: 8px") do
          if preview['image'].present?
            a(href: preview['url']) do
              div(class: "link-preview__image", style: "height: 128px; overflow: none; background: url('#{preview['image']}') center / cover no-repeat)")
            end
          end
          a(class: "text-h6", href: preview['url']) { plain preview['title'] }
          if preview['description'].present?
            p { plain preview['description'] }
          end
        end
      end
    end
  end

  def render_file_attachments
    h4(class: "text-subtitle-2") { plain t(:'common.attachments') }
    ul(class: "thread-mailer__list") do
      @resource.files.each do |file|
        download_url = Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false, host: ENV['CANONICAL_HOST'])
        div(style: "border: 1px solid #eee; border-radius: 4px; margin-bottom: 8px") do
          span { plain "\u{1F4CE}" }
          a(class: "thread-mailer__file-attachment", href: download_url, target: "_blank") do
            span(class: "thread-mailer__file-attachment-filername") { plain file.blob.filename.to_s }
          end
          span { plain number_to_human_size(file.byte_size) }
          if file.representable?
            preview_url = Rails.application.routes.url_helpers.rails_representation_url(
              file.representation(HasRichText::PREVIEW_OPTIONS),
              only_path: false,
              host: ENV['CANONICAL_HOST']
            )
            a(href: download_url, target: "_blank") do
              div(
                class: "link-preview__image",
                style: "height: 128px; overflow: none; background: url('#{preview_url}') center / contain no-repeat)"
              )
            end
          end
        end
      end
    end
  end
end
