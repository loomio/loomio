module HasRichText
  PREVIEW_OPTIONS = {resize: "1200x1200>", quality: '85'}

  extend ActiveSupport::Concern

  module ClassMethods
    def is_rich_text(on: [])
      define_singleton_method :rich_text_fields, -> { Array on }
      rich_text_fields.each do |field|
        define_method "sanitize_#{field}!" do
          tags = %w[strong em b i p s code pre big div small hr br span h1 h2 h3 h4 h5 h6 ul ol li abbr a img blockquote table thead th tr td iframe u]
          attributes = %w[href src alt title class data-type data-done data-mention-id width height target colspan rowspan]
          self[field] = Rails::Html::WhiteListSanitizer.new.sanitize(self[field], tags: tags, attributes: attributes)
          self[field] = add_required_link_attributes(self[field])
        end
        before_save :"sanitize_#{field}!"
        validates field, {length: {maximum: Rails.application.secrets.max_message_length}}
        validates_inclusion_of :"#{field}_format", in: ['html', 'md']
      end
    end
  end

  included do
    has_many_attached :files
    has_many_attached :image_files
  end

  def associate_attachments_with_group
  end

  def update_attachments!
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

    if self.respond_to?(:group) && group
      files.each { |f| f.group_id = group.id }
      image_files.each { |f| f.group_id = group.id }
    end

  end

  def attachment_icon(name)
    AppConfig.doctypes.detect{ |type| /#{type['regex']}/.match(name) }['icon']
  end

  def self.assign_attributes_and_update_files(model, params)
    model.files.each do |file|
      file.purge_later unless Array(params[:files]).include? file.signed_id
    end
    existing_ids = model.files.map(&:signed_id)
    params[:files] = Array(params[:files]).filter {|id| !existing_ids.include?(id) }
    model.reload
    model.assign_attributes(params)
  end

  private
  def add_required_link_attributes(text)
    fragment = Nokogiri::HTML::DocumentFragment.parse(text)
    fragment.css('a').each do |node|
      node['rel'] = 'nofollow ugc noreferrer noopener'
      node['target'] = '_blank'
    end
    fragment.to_s
  end
end
