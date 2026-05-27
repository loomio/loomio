# frozen_string_literal: true

class Views::Topics::Show < Views::Application::Layout
  def initialize(topic:, recipient:, pagination:, **layout_args)
    super(**layout_args)
    @topic = topic
    @recipient = recipient
    @pagination = pagination
  end

  def view_template
    div(class: "thread-page mt-12") do
      main(class: "v-main") do
        div(class: "v-container thread-page max-width-800 px-0 px-sm-3 v-locale--is-ltr") do
          div(class: "thread-card v-sheet theme--auto v-sheet--outlined elevation-1 rounded") do
            render_context_panel
            render_activity_panel
          end
        end
      end
    end
  end

  private

  def render_context_panel
    div(id: "context", class: "context-panel") do
      div(class: "d-flex align-center mr-3 ml-2 pt-2 text-body-2") do
        ul(class: "v-breadcrumbs v-breadcrumbs--density-default context-panel__breadcrumbs") do
          li(class: "v-breadcrumbs-item text-anchor py-1 ml-n2") do
            a(class: "v-breadcrumbs-item--link", href: group_url(@topic.group)) do
              plain @topic.group.full_name
            end
          end
        end
      end
      h1(id: "sequence-0", class: "text-h4 context-panel__heading px-3") { plain @topic.topicable.title }
      div(class: "mx-3 mb-2") do
        render_details
        div(class: "lmo-markdown-wrapper text-body-1 text--primary context-panel__description") do
          raw MarkdownService.render_rich_text(@topic.topicable.body, @topic.topicable.body_format)
        end
      end
    end
  end

  def render_details
    div(class: "context-panel__details my-2 text-body-2 align-center d-flex text-medium-emphasis") do
      span(class: "mr-2") do
        render Views::EventMailer::Common::Avatar.new(user: @topic.topicable.author)
      end
      span(class: "text-medium-emphasis") do
        a(href: user_url(@topic.topicable.author)) { plain @topic.topicable.author.name }
        span do
          span("aria-hidden": "true") { plain " ·" }
          plain " "
          time_ago(@topic.topicable.created_at, @recipient)
        end
        span do
          span("aria-hidden": "true") { plain " ·" }
          if @topic.private
            span(class: "nowrap context-panel__discussion-privacy context-panel__discussion-privacy--private") do
              i(class: "mdi mdi-lock-outline")
              span { plain t("common.privacy.private") }
            end
          else
            span(class: "nowrap context-panel__discussion-privacy context-panel__discussion-privacy--public") do
              i(class: "mdi mdi-earth")
              span { plain t("common.privacy.public") }
            end
          end
        end
        span do
          span("aria-hidden": "true") { plain " ·" }
          span(class: "context-panel__seen_by_count") do
            plain t("discussion_context.seen_by_count", count: @topic.seen_by_count)
          end
        end
      end
    end
  end

  def render_activity_panel
    div(class: "activity-panel") do
      items = @topic.items
        .includes(:eventable, :user)
        .order("position_key #{@topic.newest_first ? 'desc' : 'asc'}")
        .where(kind: %w[new_comment poll_created stance_created stance_updated])

      items.limit(@pagination[:limit]).offset(@pagination[:offset]).each do |item|
        if item.eventable.present?
          render Views::Topics::TopicItem.new(item: item, current_user: @recipient)
        end
      end

      if (@pagination[:offset] + @pagination[:limit]) < items.count
        a(href: "?offset=#{@pagination[:offset] + @pagination[:limit]}&limit=#{@pagination[:limit]}&export=1") do
          plain t("common.action.load_more")
        end
      end
    end
  end
end
