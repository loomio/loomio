# frozen_string_literal: true

class Views::Help::WhatsNew < Views::BasicLayout
  NEWSLETTER_URL = "https://newsletter.loomio.com/subscription/form"

  def initialize(updates:, **layout_args)
    super(**layout_args)
    @updates = updates
  end

  def view_template
    main(class: "sistema lmo-markdown-wrapper") do
      section do
        h1 { "What's new in Loomio" }
        p { "A history of features and improvements we've shipped, most recent first." }
        p do
          plain "Want to hear about new features as they ship, plus stories of Loomio being used in the world? "
          a(href: NEWSLETTER_URL, target: "_blank") { "Subscribe to the Loomio newsletter" }
          plain "."
        end
      end

      @updates.each do |update|
        article do
          p(style: "color: #888") { update[:date] }
          raw update[:html].html_safe
        end
      end
    end
  end
end
