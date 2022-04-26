class Webhook::Discord::EventSerializer < Webhook::Markdown::EventSerializer
  attributes :content

  def content
    text
  end
end
