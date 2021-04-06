class Webhook::Discord::BaseSerializer < Webhook::Markdown::BaseSerializer
  attributes :content

  def content
    text
  end
end
