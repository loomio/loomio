class Webhook::Discord::TopicItemSerializer < Webhook::Markdown::TopicItemSerializer
  attributes :content

  def content
    # discord has a 2000 char limit on webhook
    text.truncate(1900, omission: '... (truncated)')
  end
end
