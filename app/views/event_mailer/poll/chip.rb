# frozen_string_literal: true

class Views::EventMailer::Poll::Chip < Views::ApplicationMailer::Component
  def initialize(color:)
    @color = color
  end

  def view_template
    table(bgcolor: @color) do
      tr do
        td { raw "&nbsp;".html_safe }
      end
    end
  end
end
