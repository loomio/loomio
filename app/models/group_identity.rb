class GroupIdentity < ActiveRecord::Base
  belongs_to :group, class_name: 'FormalGroup'
  belongs_to :identity, class_name: 'Identities::Base'
end
