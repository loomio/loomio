class Webhook::Webex::EventSerializer < Webhook::Markdown::EventSerializer
  attributes :markdown

  def markdown
    text
  end
end
