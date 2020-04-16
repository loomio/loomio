class ConvertTeamsToWebhooks < ActiveRecord::Migration[5.2]
  def change
    Identities::Base.where(identity_type: "microsoft").each do |i|
      gi = GroupIdentity.find_by(identity_id: i.id)
      group_id = gi.group_id
      url = i.uid
      kinds = i.custom_fields['event_kinds']
      Webhook.create!(group_id: group_id, name: "Microsoft Teams Webhook", format: :microsoft, url: url, event_kinds: kinds)
      gi.destroy
    end
  end
end
