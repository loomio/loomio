class Document < ActiveRecord::Base
  belongs_to :model, polymorphic: true, required: false
  belongs_to :author, class_name: 'User', required: true
  validates :url, presence: true
  validates :title, presence: true
  validates :doctype, presence: true
  validates :color, presence: true
  before_validation :set_metadata

  has_attached_file :file, styles: lambda { |f|
    if f.instance.file_file_name.match(AppConfig.image_regex)
      { thumb: '100x100#', web: '600x>' }
    else
      {}
    end
  }
  do_not_validate_attachment_file_type :file
  after_post_process :set_initial_url

  scope :search_for, ->(query) { where("title ilike :q", q: "%#{query}%") }

  def reset_metadata!
    update(doctype: metadata['name'], icon: metadata['icon'], color: metadata['color'])
  end

  [:group, :discussion, :poll].map do |model_type|
    define_method model_type, -> { self.model.send(model_type) if self.model.respond_to?(model_type) }
  end

  def sync_urls!
    update_columns(
      url: file.url(:original),
      web_url: file.url(:web),
      thumb_url: file.url(:thumb)
    ) if file.present?
  end

  private

  # need this to save model with upload correctly and get metadata,
  # we'll set the finalized path later in set_final_urls
  def set_initial_url
    self.url ||= file&.url(:original)
  end

  def set_metadata
    self.doctype ||= metadata['name']
    self.icon    ||= metadata['icon']
    self.color   ||= metadata['color']
  end

  def metadata
    @metadata ||= Hash(AppConfig.doctypes.detect { |type| /#{type['regex']}/.match(url) })
  end
end
