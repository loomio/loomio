module HasRichText
  PREVIEW_OPTIONS = {
    resize_to_limit: [1280,1280],
    saver: {
      quality: 85,
      strip: true
    }
  }

  extend ActiveSupport::Concern

  module ClassMethods
    def is_rich_text(on: [])
      define_singleton_method :rich_text_fields, -> { Array on }
      rich_text_fields.each do |field|
        define_method "sanitize_#{field}!" do
          tags = %w[strong em b i p s code pre big div small hr br span mark h1 h2 h3 ul ol li abbr a img blockquote table thead th tr td iframe u]
          attributes = %w[href src alt title data-type data-iframe-container data-done data-mention-id data-author-id data-uid data-checked data-due-on data-color data-remind width height target colspan rowspan data-text-align]
          self[field] = Rails::Html::WhiteListSanitizer.new.sanitize(self[field], tags: tags, attributes: attributes)
          self[field] = HasRichText::strip_empty_paragraphs(self[field])
          self[field] = add_required_link_attributes(self[field])
          self[field] = HasRichText::add_heading_ids(self[field])
          self[field] = TaskService.rewrite_uids(self[field])
        end

        define_method "#{field}_visible_text" do
          if self.send("#{field}_format") == 'html'
            Nokogiri::HTML(self[field]).text
          else
            Nokogiri::HTML(MarkdownService.render_html(self[field])).text
          end
        end

        define_method "body_is_blank?" do
          self[field] == '' ||
          self[field] == nil ||
          self[field] == '<p></p>'
        end

        before_save :"sanitize_#{field}!"

        define_method "parse_and_update_tasks_#{field}!" do
          TaskService.parse_and_update(self, field)
        end
        after_save :"parse_and_update_tasks_#{field}!"

        validates field, {length: {maximum: Rails.application.secrets.max_message_length}}
        validates_inclusion_of :"#{field}_format", in: ['html', 'md']
        if respond_to?(:after_discard)
          after_discard do
            tasks.discard_all
          end
          after_undiscard do
            tasks.undiscard_all
          end
        end
      end
    end
  end

  included do
    has_many_attached :files, dependent: :detach
    has_many_attached :image_files, dependent: :detach
    has_many :tasks, as: :record
    before_save :update_content_locale
    before_save :build_attachments
    before_save :sanitize_link_previews
  end

  def update_content_locale
    return unless self.changed.intersection(self.class.rich_text_fields.map(&:to_s)).any?
    
    combined_text = self.class.rich_text_fields.map {|field| self[field] }.join(' ')
    stripped_text = Rails::Html::WhiteListSanitizer.new.sanitize(combined_text, tags: [])
    result = CLD.detect_language stripped_text
    self.content_locale = result[:code] if result[:reliable]
  end

  def sanitize_link_previews
    sanitizer = Rails::Html::FullSanitizer.new
    self.link_previews.each do |preview|
      preview.keys.each do |key|
        preview[key] = sanitizer.sanitize preview[key]
      end
    end
  end

  def build_attachments
    # this line is just to help migrations through
    return true unless self.class.column_names.include?('attachments')
    self[:attachments] = files.map do |file|
      i = file.blob.slice(:id, :filename, :content_type, :byte_size)
      i.merge!({ preview_url: Rails.application.routes.url_helpers.rails_representation_path(file.representation(PREVIEW_OPTIONS), only_path: true) }) if file.representable?
      i.merge!({ download_url: Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true) })
      i.merge!({ icon: attachment_icon(file.content_type || file.filename) })
      i.merge!({ signed_id: file.signed_id })
      i
    end
  end

  def assign_attributes_and_files(params)
    self.assign_attributes API::V1::SnorlaxBase.filter_params(self.class, params)
  end

  def attachment_icon(name)
    AppConfig.doctypes.detect{ |type| /#{type['regex']}/.match(name) }['icon']
  end

  def self.strip_empty_paragraphs(text)
    fragment = Nokogiri::HTML::DocumentFragment.parse(text)
    fragment.css('p').each do |node|
      if node.content.match?(/^[[:space:]]+$/)
        node.content = node.content.gsub(/^[[:space:]]+$/, '')
      end
    end
    fragment.to_s
  end

  def self.add_heading_ids(text)
    fragment = Nokogiri::HTML::DocumentFragment.parse(text)
    fragment.css('h1,h2,h3,h4,h5,h6').each do |node|
      node['id'] = node.text[0,60].strip.parameterize
    end
    fragment.to_s
  end

  def add_required_link_attributes(text)
    fragment = Nokogiri::HTML::DocumentFragment.parse(text)
    fragment.css('a').each do |node|
      node['rel'] = 'nofollow ugc noreferrer noopener'
      node['target'] = '_blank'
    end
    fragment.to_s
  end
end
