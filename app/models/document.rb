class Document < ActiveRecord::Base
  belongs_to :model, polymorphic: true, required: true
  validates :url, presence: true
  validates :title, presence: true
  validates :doctype, presence: true
  validates :color, presence: true
  before_validation :set_metadata

  private

  def set_metadata
    self.title   ||= "default title"
    self.doctype ||= metadata['name']
    self.color   ||= metadata['color']
  end

  def metadata
    @metadata ||= Hash(AppConfig.doctypes.detect { |type| /#{type['regex']}/.match(url) })
  end
end
