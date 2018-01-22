class GroupIdentity < ApplicationRecord
  extend HasCustomFields
  include MakesAnnouncements

  belongs_to :group, class_name: 'FormalGroup', required: true
  belongs_to :identity, class_name: 'Identities::Base', required: true

  set_custom_fields :slack_channel_id, :slack_channel_name

  attr_accessor :identity_type

  delegate :slack_team_name, to: :identity
  delegate :slack_team_id, to: :identity
end
