# frozen_string_literal: true

class Views::NotificationMailer::Common::Attachments < Views::ApplicationMailer::Component

  def initialize(resource:)
    @resource = resource
  end

  def view_template
    div(class: "email-attachments") do
      render_link_previews if @resource.link_previews.any?
      render_file_attachments if @resource.attachments.any?
    end
  end

  private

  def render_link_previews
    h4 { plain t(:'common.links') }
    ul(class: "email-list") do
      @resource.link_previews.each do |preview|
        div(style: "margin-bottom: 8px") do
          if preview['image'].present?
            a(href: preview['url']) do
              div(style: "height: 128px; overflow: none; background: url('#{preview['image']}') center / cover no-repeat")
            end
          end
          a(class: "email-attachment-title", href: preview['url']) { plain preview['title'] }
          if preview['description'].present?
            p { plain preview['description'] }
          end
        end
      end
    end
  end

  def render_file_attachments
    h4 { plain t(:'common.attachments') }
    ul(class: "email-list") do
      @resource.files.each do |file|
        download_url = Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false, host: ENV['CANONICAL_HOST'])
        div(style: "margin-bottom: 8px") do
          span { plain "\u{1F4CE}" }
          a(href: download_url, target: "_blank") do
            span { plain file.blob.filename.to_s }
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
                style: "height: 128px; overflow: none; background: url('#{preview_url}') center / contain no-repeat"
              )
            end
          end
        end
      end
    end
  end
end
