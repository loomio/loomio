class Document < ActiveRecord::Base
  belongs_to :model, polymorphic: true, required: false
  belongs_to :author, class_name: 'User', required: true
  validates :url, presence: true
  validates :title, presence: true
  validates :doctype, presence: true
  validates :color, presence: true
  before_validation :set_metadata

  scope :search_for, ->(query) { where("title ilike :q", q: "%#{query}%") }

  def reset_metadata!
    update(doctype: metadata['name'], icon: metadata['icon'], color: metadata['color'])
  end

  [:group, :discussion, :poll].map do |model_type|
    define_method model_type, -> { self.model.send(model_type) if self.model.respond_to?(model_type) }
  end

  private

  def set_metadata
    self.doctype ||= metadata['name']
    self.icon    ||= metadata['icon']
    self.color   ||= metadata['color']
  end

  def metadata
    @metadata ||= Hash(AppConfig.doctypes.detect { |type| /#{type['regex']}/.match(url) })
  end
end
