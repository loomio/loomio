module Linkable
  extend ActiveSupport::Concern

  included do    
    attr_accessible :hotlink_attributes
    after_initialize :initialize_hotlink
    
    has_one :hotlink, as: :linkable    
    accepts_nested_attributes_for :hotlink, allow_destroy: true, reject_if: :all_blank
  end
  
  private
  
  def initialize_hotlink
    build_hotlink unless hotlink
  end
  
end