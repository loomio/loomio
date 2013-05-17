class Campaign < ActiveRecord::Base
  attr_accessible :showcase_url, :name, :manager_email
end
