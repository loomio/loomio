class OrganisationVisit < ActiveRecord::Base
  belongs_to :organisation, class_name: 'Group'
  belongs_to :visit
  belongs_to :user
end
