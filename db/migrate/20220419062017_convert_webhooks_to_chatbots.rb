class ConvertWebhooksToChatbots < ActiveRecord::Migration[6.1]
  def change
    Webhook.all.each do |webhook|
      Chatbot.create(
        kind: "webhook",
        group_id: webhook.group_id,
        name: webhook.name,
        server: webhook.url,
        webhook_kind: webhook.format,
        author_id: webhook.author_id,
        notification_only: !webhook.include_body,
        event_kinds: webhook.event_kinds,
        created_at: webhook.created_at,
        updated_at: webhook.updated_at,
      )
    end
  end
end
