# frozen_string_literal: true

class Views::Discussions::ThreadItems::NewComment < Views::Application::Component
  def initialize(item:, current_user:)
    @item = item
    @current_user = current_user
  end

  def view_template
    comment = @item.eventable
    div(class: "new-comment", id: "comment-#{comment.id}") do
      div(class: "thread-item px-3 pb-1") do
        div(id: "sequence-2", class: "d-flex lmo-action-dock-wrapper", style: "margin-left: 0px;") do
          div(class: "thread-item__avatar mr-3 mt-0") do
            render Views::EventMailer::Common::Avatar.new(user: comment.author)
          end
          div(class: "layout thread-item__body column") do
            div(class: "layout align-center wrap") do
              h3(class: "thread-item__title text-body-2", id: "event-#{@item.id}") do
                span do
                  strong do
                    a(href: user_url(comment.author)) { plain comment.author.name }
                  end
                end
                span do
                  span("aria-hidden": "true") { plain " \u00b7" }
                end
                span(class: "text--secondary text-body-2") do
                  time_ago(comment.created_at, @current_user)
                end
              end
            end
            div(class: "default-slot") do
              div(class: "lmo-markdown-wrapper text-body-1 text--primary thread-item__body new-comment__body") do
                raw MarkdownService.render_rich_text(comment.body, comment.body_format)
              end
            end
          end
        end
      end
    end
  end
end
