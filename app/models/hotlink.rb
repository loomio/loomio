class HotlinkValidator < ActiveModel::Validator
  def validate(record)
    return if record.short_url.blank?
    
    route = Rails.application.routes.recognize_path "/#{record.short_url}"
    route_exists = route[:controller] != "hotlinks" || route[:action] != "show"
    
    record.errors[:short_url] << "/#{record.short_url} has already been taken" if route_exists
  end
end

class Hotlink < ActiveRecord::Base
  after_save :destroy_record, if: :short_url_is_blank?
  belongs_to :linkable, polymorphic: true

  default_scope where('short_url IS NOT NULL')
  
  def self.find_by_link(link)
    includes(:linkable).where(short_url: link).first
  end
  
  validates_with HotlinkValidator
  validates :linkable_id, :linkable_type, presence: true
  validates :short_url, uniqueness: true, allow_blank: true

  private
  
  def short_url_is_blank?
    short_url.blank?
  end
  
  def destroy_record
    Hotlink.destroy id if id
  end

end