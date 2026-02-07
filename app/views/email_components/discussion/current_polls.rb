# frozen_string_literal: true

class Views::EmailComponents::Discussion::CurrentPolls < Views::Base
  include Phlex::Rails::Helpers::T
  include EmailHelper

  def initialize(discussion:, recipient:)
    @discussion = discussion
    @recipient = recipient
  end

  def view_template
    polls = @discussion.polls.active.order('closing_at asc')
    return unless polls.any?

    h3(class: "text-h6 mb-2") { plain t('dashboard_page.current_polls') }
    table(style: "padding: 0; margin-bottom: 8px") do
      polls.each do |poll|
        stance = recipient_stance(@recipient, poll)
        tr do
          td { plain plain_text(poll, :title) }
          td do
            if @recipient.can?(:vote_in, poll)
              if stance && stance.cast_at?
                plain t('poll_mailer.common.you_voted')
              else
                a(href: polymorphic_url(poll)) { plain t('poll_mailer.common.vote_now') }
              end
            else
              plain t('poll_mailer.common.not_invited')
            end
          end
        end
      end
    end
  end
end
