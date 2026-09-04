# frozen_string_literal: true

class Views::Subscriptions::Unavailable < Views::BasicLayout
  def initialize
    super(title: "Subscriptions unavailable")
  end

  def view_template
    main(class: "sistema") do
      h1 { "Subscriptions are unavailable" }
      p { "The subscription service could not be reached. Try again later." }
    end
  end
end
