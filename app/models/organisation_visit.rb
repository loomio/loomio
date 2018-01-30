class OrganisationVisit < ApplicationRecord
  belongs_to :organisation, class_name: 'Group'
  belongs_to :visit
  belongs_to :user
end
