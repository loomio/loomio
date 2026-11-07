# frozen_string_literal: true

class Views::Topics::Show < Views::Application::Layout
  def initialize(topic:, recipient:, pagination:, **layout_args)
    super(**layout_args)
    @topic = topic
    @recipient = recipient
    @pagination = pagination
  end

  def view_template
    preload_context
    load_activity

    div(class: "topic-page mt-12") do
      main(class: "v-main") do
        div(class: "v-container topic-page max-width-800 px-0 px-sm-3 v-locale--is-ltr") do
          article(class: "topic-card v-sheet theme--auto v-sheet--outlined elevation-1 rounded") do
            render_context_panel
            render_activity_panel
          end
        end
      end
    end
    render_structured_data unless @export
  end

  # Crawlers and link previews treat a thread or poll as an article.
  def page_meta
    {
      type: "article",
      published_time: @topic.topicable.created_at,
      modified_time: @topic.last_activity_at
    }
  end

  private

  def render_context_panel
    div(id: "context", class: "context-panel") do
      if @topic.group
        nav(class: "d-flex align-center mr-3 ml-2 pt-2 text-body-2", "aria-label": "breadcrumb") do
          ul(class: "v-breadcrumbs v-breadcrumbs--density-default context-panel__breadcrumbs") do
            li(class: "v-breadcrumbs-item text-anchor py-1 ml-n2") do
              a(class: "v-breadcrumbs-item--link", href: group_url(@topic.group)) do
                plain @topic.group.full_name
              end
            end
          end
        end
      end
      h1(id: "sequence-0", class: "text-h4 context-panel__heading px-3") { plain @topic.topicable.title }
      div(class: "mx-3 mb-2") do
        render_details
        # A standalone poll's details appear on its poll card below.
        if @topic.topicable.is_a?(Discussion)
          div(class: "lmo-markdown-wrapper text-body-1 text--primary context-panel__description") do
            raw MarkdownService.render_rich_text(@topic.topicable.body, @topic.topicable.body_format)
          end
        end
      end
    end
  end

  def render_details
    div(class: "context-panel__details my-2 text-body-2 align-center d-flex text-medium-emphasis") do
      span(class: "mr-2") do
        render Views::NotificationMailer::Common::Avatar.new(user: @topic.topicable.author)
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

  def load_activity
    scope = @topic.items
      .includes(:itemable, :user)
      .order("position_key #{@topic.newest_first ? 'desc' : 'asc'}")
      .where(kind: %w[new_comment poll_created stance_created stance_updated])
      .where.not(itemable_type: 'Stance', itemable_id: stance_ids_hidden_from_activity)

    @total = scope.count
    @items = scope.limit(@pagination[:limit]).offset(@pagination[:offset]).to_a.select { |item| item.itemable.present? }
    preload_activity(@items)
  end

  def render_activity_panel
    section(class: "activity-panel") do
      @items.each do |item|
        render Views::Topics::TopicItem.new(item: item, current_user: @recipient, topicable: @topic.topicable)
      end
      render_page_links
    end
  end

  # Exports page with ?export=1 and stay out of search results. Crawlers follow
  # plain ?offset= pages, each its own canonical URL, so every item is indexed.
  def render_page_links
    offset, limit = @pagination.values_at(:offset, :limit)
    previous_offset = offset - limit if offset > 0
    next_offset = offset + limit if offset + limit < @total
    return unless previous_offset || next_offset

    nav(class: "topic-page__pages pa-3 d-flex justify-space-between") do
      a(href: page_href([previous_offset, 0].max), rel: page_rel("prev")) { plain t("common.action.back") } if previous_offset
      a(href: page_href(next_offset), rel: page_rel("next")) { plain t("common.action.load_more") } if next_offset
    end
  end

  def page_rel(direction)
    @export ? "#{direction} nofollow" : direction
  end

  def page_href(offset)
    if @export
      "?offset=#{offset}&limit=#{@pagination[:limit]}&export=1"
    else
      offset.zero? ? "?" : "?offset=#{offset}"
    end
  end

  def render_structured_data
    topicable = @topic.topicable
    comments = @items.filter_map { |item| item.itemable if item.kind == "new_comment" }
    data = {
      "@context": "https://schema.org",
      "@type": "DiscussionForumPosting",
      headline: topicable.title,
      text: MarkdownService.render_excerpt(topicable.body, topicable.body_format, length: 5000),
      url: @canonical_url,
      datePublished: topicable.created_at.iso8601,
      dateModified: @topic.last_activity_at&.iso8601,
      author: person(topicable.author),
      interactionStatistic: {
        "@type": "InteractionCounter",
        interactionType: "https://schema.org/CommentAction",
        userInteractionCount: @topic.items.where(kind: "new_comment").count
      },
      comment: comments.map do |comment|
        {
          "@type": "Comment",
          text: MarkdownService.render_excerpt(comment.body, comment.body_format, length: 5000),
          datePublished: comment.created_at.iso8601,
          author: person(comment.author),
          url: ("#{@canonical_url}#comment-#{comment.id}" if @canonical_url)
        }.compact
      end
    }.compact
    script(type: "application/ld+json") { raw safe(ERB::Util.json_escape(data.to_json)) }
  end

  def person(user)
    { "@type": "Person", name: user.name, url: user_url(user) }
  end

  def stance_ids_hidden_from_activity
    polls = @topic.polls
    hidden_poll_ids = polls.reject do |poll|
      poll.results_available?
    end.map(&:id)

    Stance.where(poll_id: hidden_poll_ids).where.not(participant_id: @recipient.id).select(:id)
  end

  # The export view renders several polymorphic activity types. Preload each
  # type's complete rendering graph so the number of queries does not grow with
  # the number of comments, polls, outcomes, or stances on the page.
  def preload_activity(items)
    comments = items.filter_map { |i| i.itemable if i.kind == 'new_comment' }
    stances  = items.filter_map { |i| i.itemable if i.kind.in?(%w[stance_created stance_updated]) }
    polls    = items.filter_map { |i| i.itemable if i.kind == 'poll_created' }

    ActiveRecord::Associations::Preloader.new(records: comments, associations: {user: {uploaded_avatar_attachment: :blob}}).call if comments.any?
    ActiveRecord::Associations::Preloader.new(
      records: stances,
      associations: [:poll, {participant: {uploaded_avatar_attachment: :blob}}]
    ).call if stances.any?
    ActiveRecord::Associations::Preloader.new(
      records: polls,
      associations: [
        :poll_options,
        {author: {uploaded_avatar_attachment: :blob}},
        {current_outcome: :author}
      ]
    ).call if polls.any?
  end

  def preload_context
    ActiveRecord::Associations::Preloader.new(records: [@topic], associations: [:group, :topicable]).call
    topicable = @topic.topicable
    ActiveRecord::Associations::Preloader.new(
      records: [topicable],
      associations: {author: {uploaded_avatar_attachment: :blob}}
    ).call
  end
end
