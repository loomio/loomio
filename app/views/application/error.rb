# frozen_string_literal: true

class Views::Application::Error < Views::BasicLayout
  def initialize(title:, body:)
    super(title: title)
    @body = body
  end

  def view_template
    main(class: "sistema") do
      h1 { plain @title }
      raw sanitize(@body, tags: %w[a], attributes: %w[href])
    end
  end
end
