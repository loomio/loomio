class Document < ApplicationRecord
  belongs_to :model, polymorphic: true, required: false
  belongs_to :author, class_name: 'User', required: true
  validates :title, presence: true
  validates :doctype, presence: true
  validates :color, presence: true
  before_validation :set_metadata

  before_save :set_group_id

  has_one_attached :file

  scope :search_for, ->(query) {
    if query.present?
      where("title ilike :q", q: "%#{query}%")
    else
      all
    end
  }

  def download_url
    return nil unless file.attached?
    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  end

  def reset_metadata!
    update(doctype: metadata['name'], icon: metadata['icon'], color: metadata['color'])
  end

  [:group, :discussion, :poll].map do |model_type|
    define_method model_type, -> { self.model.send(model_type) if self.model.respond_to?(model_type) }
  end

  def is_an_image?
    metadata['icon'] == 'image'
  end

  def url
    return file.url if file.attached?
    return nil unless self[:url]
    self[:url].to_s.starts_with?("http") ? self[:url] : "#{lmo_asset_host}#{self[:url]}"
  end

  private

  def set_group_id
    self.group_id = model.group_id if model && model.respond_to?(:group_id)
  end

  def set_metadata
    self.doctype ||= metadata['name']
    self.icon    ||= metadata['icon']
    self.color   ||= metadata['color']
  end

  def metadata
    @metadata ||= Hash(AppConfig.doctypes.detect { |type| /#{type['regex']}/.match(file.content_type || url) })
  end
end
