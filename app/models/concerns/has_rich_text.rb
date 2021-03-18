module HasRichText
  PREVIEW_OPTIONS = {resize: "1200x1200>", quality: '85'}

  extend ActiveSupport::Concern

  module ClassMethods
    def is_rich_text(on: [])
      define_singleton_method :rich_text_fields, -> { Array on }
      rich_text_fields.each do |field|
        define_method "sanitize_#{field}!" do
          tags = %w[strong em b i p s code pre big div small hr br span h1 h2 h3 h4 h5 h6 ul ol li abbr a img blockquote table thead th tr td iframe u]
          attributes = %w[href src alt title class data-type data-done data-mention-id width height target colspan rowspan data-text-align background style]
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
    before_save :caclulate_content_locale
    before_save :build_attachments
  end

  def caclulate_content_locale
    combined_text = self.class.rich_text_fields.map {|field| self[field] }.join(' ')
    stripped_text = Rails::Html::WhiteListSanitizer.new.sanitize(combined_text, tags: [])
    result = CLD.detect_language stripped_text
    self.content_locale = result[:code] if result[:reliable]
  end

  def build_attachments
    # this line is just to help migrations through
    return true unless self.class.column_names.include?('attachments')
    self[:attachments] = files.map do |file|
      i = file.blob.slice(:id, :filename, :content_type, :byte_size)
      i.merge!({ preview_url: Rails.application.routes.url_helpers.rails_representation_path(file.representation(PREVIEW_OPTIONS), only_path: true) }) if file.representable?
      i.merge!({ download_url: Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true) })
      i.merge!({ icon: attachment_icon(file.blob.content_type || file.blob.filename) })
      i.merge!({ signed_id: file.signed_id })
      i
    end
  end

  def purge_removed_files(params)
    self.files.each do |file|
      file.purge_later unless Array(params[:files]).include? file.signed_id
    end
    self.reload
  end

  def attachment_icon(name)
    AppConfig.doctypes.detect{ |type| /#{type['regex']}/.match(name) }['icon']
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
