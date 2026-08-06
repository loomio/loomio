module HasRichText
  INLINE_BLOB_SIGNED_ID_PATTERN = %r{
    /rails/active_storage/
    (?:blobs|representations)
    (?:/(?:redirect|proxy))?/
    ([^/\s?"'<>]+)
  }x.freeze

  PREVIEW_OPTIONS = {
    resize_to_limit: [1280,1280],
    saver: {
      quality: 85,
      strip: true
    }
  }

  extend ActiveSupport::Concern

  def self.inline_blob_signed_ids(text)
    String(text).scan(INLINE_BLOB_SIGNED_ID_PATTERN).flatten.uniq
  end

  def self.inline_blobs(record)
    signed_ids = record.class.rich_text_fields.flat_map do |field|
      inline_blob_signed_ids(record[field])
    end

    signed_ids.uniq.filter_map { |signed_id| ActiveStorage::Blob.find_signed(signed_id) }.uniq(&:id)
  end

  module ClassMethods
    def is_rich_text(on: [])
      define_singleton_method :rich_text_fields, -> { Array on }
      rich_text_fields.each do |field|
        define_method "sanitize_#{field}!" do
          # return if self.send("#{field}_format") == 'md'
          tags = %w[strong em b i p s code pre big div small hr br span mark h1 h2 h3 ul ol li abbr a img video audio blockquote table thead th tr td iframe u]
          attributes = %w[href src alt title data-type data-iframe-container data-done data-mention-id poster controls data-author-id data-uid data-checked data-due-on data-color data-remind width height target colspan rowspan data-text-align]

          self[field] = Rails::Html::WhiteListSanitizer.new.sanitize(self[field], tags: tags, attributes: attributes)
          self[field] = HasRichText::strip_empty_paragraphs(self[field])
          self[field] = add_required_link_attributes(self[field])
          self[field] = HasRichText::add_heading_ids(self[field])
          self[field] = TaskService.rewrite_uids(self[field])
          # preserve markdown quotes after html sanitizer
          self[field] = self[field].gsub(/^\s*\\*&gt\; /, '> ') if self.send("#{field}_format") == 'md'
        end

        define_method "#{field}_visible_text" do
          if self.send("#{field}_format") == 'html'
            Nokogiri::HTML(self[field]).text
          else
            Nokogiri::HTML(MarkdownService.render_html(self[field])).text
          end
        end

        define_method "#{field}_visible_text_length" do
          self.send("#{field}_visible_text").encode("UTF-16LE").bytesize / 2
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

        validates field, {length: {maximum: AppConfig.app_features[:max_message_length]}}
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
        preview[key] = String(sanitizer.sanitize preview[key]).truncate(480)
      end
    end
  end

  # Rich text intentionally stores stable Active Storage blob and representation
  # paths, not temporary storage-service URLs. Active Storage resolves these
  # signed bearer URLs to a fresh service URL on each request, so embedded files
  # do not break when a service URL expires or the storage service changes.
  #
  # These URLs must also work without a Loomio session because rich text is
  # rendered in email, chatbots, and exports. Possession of the unguessable URL
  # therefore grants access to the file; authorization is not re-checked against
  # the group or record on download. Changing that access model requires a design
  # for signed-out renderers as well as the web application.
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
    params = params.dup

    # Ignore nil rather than accidentally removing regular attachments.
    files = params.delete(:files) { params.delete("files") }
    params[:files] = files unless files.nil?

    image_file_attachables = params.delete(:image_files) { params.delete("image_files") }

    self.assign_attributes Api::V1::SnorlaxBase.filter_params(self.class, params)
    attach_inline_image_files(image_file_attachables)
  end

  def attach_inline_image_files(image_file_attachables)
    existing_blob_ids = image_files.blobs.map(&:id)
    attachables = Array(image_file_attachables).map do |attachable|
      attachable.is_a?(String) ? ActiveStorage::Blob.find_signed(attachable) || attachable : attachable
    end
    attachables.concat(inline_image_blobs)
    attachables.uniq! do |attachable|
      attachable.is_a?(ActiveStorage::Blob) ? [:blob, attachable.id] : attachable
    end
    attachables.reject! do |attachable|
      attachable.is_a?(ActiveStorage::Blob) && existing_blob_ids.include?(attachable.id)
    end

    image_files.attach(attachables) if attachables.present?
  end

  def inline_image_blobs
    HasRichText.inline_blobs(self)
  end

  private :attach_inline_image_files, :inline_image_blobs

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
      if String(node['href']).starts_with?("https://#{ENV['CANONICAL_HOST']}")
        node['rel'] = nil
        node['target'] = nil
      else
        node['rel'] = 'nofollow ugc noreferrer noopener'
        node['target'] = '_blank'
      end
    end
    fragment.to_s
  end
end
