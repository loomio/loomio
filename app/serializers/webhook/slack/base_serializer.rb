class Webhook::Slack::BaseSerializer < Webhook::Markdown::BaseSerializer
  def blocks
    # if markdown then parse markdown to images
    fragment = Nokogiri::HTML::DocumentFragment.parse(body_as_html)
    fragment.css('img').map do |node|
      { type: 'image', image_url: node.src }
    end
  end

  def body_as_html
    body
    # if body_format == "md"
    #   renderer = LoomioMarkdown.new(filter_html: true, hard_wrap: true, link_attributes: {rel: "nofollow ugc noreferrer noopener", target: :_blank})
    #   Redcarpet::Markdown.new(renderer, *MARKDOWN_OPTIONS).render(body)
    # else
    #   body
    # end
  end

  def headline
    SlackMrkdwn.from(super.to_s)
  end

  def body
    SlackMrkdwn.from(super.to_s)
  end
end
