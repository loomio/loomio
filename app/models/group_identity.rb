class GroupIdentity < ActiveRecord::Base
  extend HasCustomFields
  
  belongs_to :group, class_name: 'FormalGroup'
  belongs_to :identity, class_name: 'Identities::Base'

  set_custom_fields :slack_channel_id, :slack_channel_name

  delegate :slack_team_name, to: :identity
  delegate :slack_team_id, to: :identity
end
