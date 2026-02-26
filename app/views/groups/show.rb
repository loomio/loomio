# frozen_string_literal: true

class Views::Groups::Show < Views::Application::Layout
  def initialize(group:, recipient:, **layout_args)
    super(**layout_args)
    @group = group
    @recipient = recipient
  end

  def view_template
    div(class: "group-page mt-12") do
      main(class: "v-main") do
        div(class: "v-main__wrap") do
          div do
            div(class: "container gruop-page max-width-1024 px-0 px-sm-3") do
              div(class: "v-responsive v-image", style: "border-radius: 8px;") do
                div(class: "v-responsive__sizer", style: "padding-bottom: 20.4082%;")
                div(class: "v-image__image v-image__image--cover", style: "background-image: url(#{@group.cover_url}); background-position: center center;")
              end
              h1(class: "text-h4 my-4") do
                span(class: "group-page__name mr-4") { plain @group.full_name }
              end
              div(class: "lmo-markdown-wrapper text-body-2 text--primary group-page__description") do
                raw MarkdownService.render_rich_text(@group.description, @group.description_format)
              end
              hr(class: "mt-4 v-divider theme--auto", "aria-orientation": "horizontal", role: "separator")
              render_discussions_panel
            end
          end
        end
      end
    end
  end

  private

  def render_discussions_panel
    div(class: "discussions-panel") do
      div(class: "discussions-panel v-card v-card--outlined v-sheet theme--auto mt-2") do
        div do
          div(class: "discussions-panel__content") do
            div(class: "discussions-panel__list thread-preview-collection__container") do
              div(class: "v-list thread-previews v-sheet v-sheet--tile theme--auto v-list--two-line", role: "list") do
                @group.discussions.kept.joins(:topic).where(topics: { private: false }).order("topics.last_activity_at desc nulls last").limit(50).each do |discussion|
                  a(class: "thread-preview thread-preview__link v-list-item v-list-item--link theme--auto", href: discussion_url(discussion), role: "listitem", tabindex: "0") do
                    div(class: "v-list-item__avatar") do
                      render Views::EventMailer::Common::Avatar.new(user: discussion.author)
                    end
                    div(class: "v-list-item__content") do
                      div(class: "v-list-item__title", style: "align-items: center;") do
                        span(class: "thread-preview__title") { plain discussion.title }
                      end
                      div(class: "v-list-item__subtitle") do
                        span(class: "thread-preview__items-count") { plain t("thread_preview.replies_count", count: discussion.topic.replies_count) }
                        span
                        comment { "/" }
                        span do
                          span("aria-hidden": "true") { plain " \u00b7" }
                        end
                        span { plain t("common.active_time_ago", time_ago: discussion.last_activity_at.to_formatted_s(:long_ordinal)) }
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
