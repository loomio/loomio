class Document < ActiveRecord::Base
  belongs_to :model, polymorphic: true, required: false
  belongs_to :author, class_name: 'User', required: true
  validates :url, format: { with: AppConfig::URL_REGEX, message: I18n.t(:"document.error.invalid_format") }, if: :manual_url?
  validates :title, presence: true
  validates :doctype, presence: true
  validates :color, presence: true
  before_validation :set_metadata

  has_attached_file :file, styles: lambda { |f|
    if f.instance.is_an_image?
      { thumb: '100x100#', web: '600x>' }
    else
      {}
    end
  }
  do_not_validate_attachment_file_type :file
  after_post_process :set_initial_url

  scope :search_for, ->(query) {
    if query.present?
      where("title ilike :q", q: "%#{query}%")
    else
      all
    end
  }

  def reset_metadata!
    update(doctype: metadata['name'], icon: metadata['icon'], color: metadata['color'])
  end

  [:group, :discussion, :poll].map do |model_type|
    define_method model_type, -> { self.model.send(model_type) if self.model.respond_to?(model_type) }
  end

  def sync_urls!
    update(
      url:       file.url,
      web_url:   (file.url(:web) if is_an_image?),
      thumb_url: (file.url(:thumb) if is_an_image?)
    ) unless manual_url?
  end

  def is_an_image?
    file_file_name.to_s.match(AppConfig.image_regex)
  end

  def manual_url?
    self.file.blank?
  end

  private

  # need this to save model with upload correctly and get metadata,
  # we'll set the finalized path later in set_final_urls
  def set_initial_url
    self.url = file.url unless manual_url?
  end

  def set_metadata
    self.doctype ||= metadata['name']
    self.icon    ||= metadata['icon']
    self.color   ||= metadata['color']
  end

  private

  def metadata
    @metadata ||= Hash(AppConfig.doctypes.detect { |type| /#{type['regex']}/.match(url) })
  end
end
