module HasRichText
  PREVIEW_OPTIONS = {resize: "1200x1200>", quality: '85'}

  extend ActiveSupport::Concern

  module ClassMethods
    def is_rich_text(on: [])
      define_singleton_method :rich_text_fields, -> { Array on }
      rich_text_fields.each do |field|
        define_method "sanitize_#{field}!" do
          if self["#{field}_format"] == "html"
            tags = %w[strong em b i p s code pre big div small hr br span h1 h2 h3 h4 h5 h6 ul ol li abbr a img blockquote table thead th tr td]
            attributes = %w[href src alt title class data-type data-done data-mention-id width height target]
            self[field] = Rails::Html::WhiteListSanitizer.new.sanitize(self[field], tags: tags, attributes: attributes)
          end
        end
        before_save :"sanitize_#{field}!"
        validates field, {length: {maximum: Rails.application.secrets.max_message_length}}
      end
    end
  end

  included do
    has_many_attached :files
    has_many_attached :image_files
    before_save :build_attachments
    before_save :associate_attachments_with_group
  end

  def associate_attachments_with_group
    if self[:group_id] && group
      files.update_all(group_id: self[:group_id])
      image_files.update_all(group_id: self[:group_id])
    end
  end

  def build_attachments
    # this line is just to help migrations through
    return true unless self.class.column_names.include?('attachments')
    self[:attachments] = files.map do |file|
      i = file.blob.slice(:id, :filename, :content_type, :byte_size)
      i.merge!({ preview_url: Rails.application.routes.url_helpers.rails_representation_path(file.representation(PREVIEW_OPTIONS), only_path: true) }) if file.representable?
      i.merge!({ download_url: Rails.application.routes.url_helpers.rails_blob_path(file, disposition: "attachment", only_path: true) })
      i.merge!({ icon: attachment_icon(file.blob.content_type || file.blob.filename) })
      i.merge!({ signed_id: file.signed_id })
      i
    end
  end

  def attachment_icon(name)
    AppConfig.doctypes.detect{ |type| /#{type['regex']}/.match(name) }['icon']
  end

  def self.assign_attributes_and_update_files(model, params)
    # byebug
    model.files.each do |file|
      file.purge_later unless Array(params[:files]).include? file.signed_id
    end
    existing_ids = model.files.map(&:signed_id)
    params[:files] = params[:files].filter {|id| !existing_ids.include?(id) }
    model.reload
    model.assign_attributes(params)
  end
end
