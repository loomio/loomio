module HasRichText
  PREVIEW_OPTIONS = {resize: "1200x1200>", quality: '85'}

  extend ActiveSupport::Concern

  module ClassMethods
    def is_rich_text(on: [])
      define_singleton_method :rich_text_fields, -> { Array on }
      rich_text_fields.each do |field|
        define_method "#{field}=" do |content|
          tags = %w[strong em b i p code pre big div small hr br span h1 h2 h3 h4 h5 h6 ul ol li abbr a img blockquote]
          attributes = %w[href src alt title class data-type data-done data-mention-id]
          self[field] = Rails::Html::WhiteListSanitizer.new.sanitize(content, tags: tags, attributes: attributes)
        end
        validates field, {length: {maximum: Rails.application.secrets.max_message_length}}
      end
    end
  end

  included do
    has_many_attached :files
    has_many_attached :image_files
    before_save :build_attachments
  end

  def build_attachments
    self[:attachments] = files.map do |file|
      i = file.blob.slice(:id, :filename, :content_type, :byte_size)
      i.merge!({ preview_url: Rails.application.routes.url_helpers.rails_representation_path(file.representation(PREVIEW_OPTIONS), only_path: true) }) if file.representable?
      i.merge!({ download_url: Rails.application.routes.url_helpers.rails_blob_path(file, disposition: "attachment", only_path: true) })
      i.merge!({ icon: attachment_icon(file.blob.content_type || file.blob.filename) })
      i
    end
  end

  def attachment_icon(name)
    AppConfig.doctypes.detect{ |type| /#{type['regex']}/.match(name) }['icon']
  end
end
