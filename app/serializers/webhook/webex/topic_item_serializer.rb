class Webhook::Webex::TopicItemSerializer < Webhook::Markdown::TopicItemSerializer
  attributes :markdown

  def markdown
    text
  end
end
