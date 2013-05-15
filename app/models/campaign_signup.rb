class CampaignSignup < ActiveRecord::Base
  belongs_to :campaign
  attr_accessible :email, :name, :campaign, :spam
end
