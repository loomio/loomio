# frozen_string_literal: true

class Views::Groups::Show < Views::Application::Layout
  PAGE_SIZE = 50

  def initialize(group:, recipient:, page: 1, **layout_args)
    super(**layout_args)
    @group = group
    @recipient = recipient
    @page = [page.to_i, 1].max
  end

  def view_template
    div(class: "group-page mt-12") do
      main(class: "v-main") do
        div(class: "v-main__wrap") do
          div(class: "container group-page max-width-1024 px-0 px-sm-3") do
            if @group.cover_url
              div(class: "v-responsive v-image", style: "border-radius: 8px;") do
                div(class: "v-responsive__sizer", style: "padding-bottom: 20.4082%;")
                div(class: "v-image__image v-image__image--cover", style: "background-image: url(#{@group.cover_url}); background-position: center center;")
              end
            end
            h1(class: "text-h4 my-4") do
              span(class: "group-page__name mr-4") { plain @group.full_name }
            end
            div(class: "lmo-markdown-wrapper text-body-2 text--primary group-page__description") do
              raw MarkdownService.render_rich_text(@group.description, @group.description_format)
            end
            render_subgroups
            hr(class: "mt-4 v-divider theme--auto")
            render_topics_panel
          end
        end
      end
    end
  end

  private

  # Public threads and standalone polls, newest activity first, as the app lists them.
  def public_topics
    @public_topics ||= Topic.where(group_id: @group.id, private: false, discarded_at: nil)
      .with_topicable
      .order(Arel.sql("topics.last_activity_at DESC NULLS LAST"), id: :desc)
  end

  def page_topics
    topics = public_topics.limit(PAGE_SIZE).offset((@page - 1) * PAGE_SIZE).to_a
    ActiveRecord::Associations::Preloader.new(records: topics, associations: :topicable).call
    ActiveRecord::Associations::Preloader.new(
      records: topics.map(&:topicable), associations: { author: { uploaded_avatar_attachment: :blob } }
    ).call
    topics
  end

  def render_subgroups
    subgroups = @group.subgroups.visible_to_public.order(:name).to_a
    return if subgroups.empty?

    nav(class: "group-page__subgroups mt-4", "aria-label": t("group_page.subgroups")) do
      h2(class: "text-h6") { plain t("group_page.subgroups") }
      ul do
        subgroups.each do |subgroup|
          li { a(href: group_url(subgroup)) { plain subgroup.name } }
        end
      end
    end
  end

  def render_topics_panel
    section(class: "discussions-panel v-card v-card--outlined v-sheet theme--auto mt-2") do
      ul(class: "discussions-panel__list topic-previews v-list v-sheet v-sheet--tile theme--auto v-list--two-line") do
        page_topics.each { |topic| render_topic_preview(topic) }
      end
      render_page_links
    end
  end

  def render_topic_preview(topic)
    topicable = topic.topicable
    url = topicable.is_a?(Poll) ? poll_url(topicable) : discussion_url(topicable)
    li(class: "topic-preview v-list-item theme--auto") do
      div(class: "v-list-item__avatar") do
        render Views::NotificationMailer::Common::Avatar.new(user: topicable.author)
      end
      div(class: "v-list-item__content") do
        a(class: "topic-preview__link topic-preview__title v-list-item__title", href: url) { plain topicable.title }
        div(class: "v-list-item__subtitle") do
          span(class: "topic-preview__items-count") { plain t("thread_preview.items_count", count: topic.items_count) }
          if topic.last_activity_at
            span("aria-hidden": "true") { plain " · " }
            time_ago(topic.last_activity_at, @recipient)
          end
        end
      end
    end
  end

  def render_page_links
    pages = (public_topics.count.to_f / PAGE_SIZE).ceil
    return if pages <= 1

    nav(class: "group-page__pages pa-3 d-flex justify-space-between") do
      a(href: page_href(@page - 1), rel: "prev") { plain t("common.action.back") } if @page > 1
      a(href: page_href(@page + 1), rel: "next") { plain t("common.action.next") } if @page < pages
    end
  end

  def page_href(page)
    query = { page: (page if page > 1), export: (1 if @export) }.compact
    query.empty? ? "?" : "?#{query.to_query}"
  end
end
