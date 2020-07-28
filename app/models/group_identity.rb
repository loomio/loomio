class GroupIdentity < ApplicationRecord
  extend HasCustomFields

  attr_writer :make_announcement
  def make_announcement
    !!@make_announcement
  end

  attr_accessor :webhook_url

  belongs_to :group, class_name: 'Group', required: true
  belongs_to :identity, class_name: 'Identities::Base', required: true, dependent: :destroy

  set_custom_fields :slack_channel_id, :slack_channel_name

  attr_accessor :identity_type

  delegate :slack_team_name, to: :identity
  delegate :slack_team_id, to: :identity
  delegate :title, to: :group
end
