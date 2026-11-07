require 'builder'

# Lists the public groups, threads and polls that signed-out visitors can see,
# so crawlers can find them without following every group page. Sitemaps are
# only served where robots are allowed. Each file holds at most 50,000 URLs.
class SitemapsController < ActionController::Base
  PAGE_SIZE = 50_000

  before_action { head :not_found unless ENV.key?('ALLOW_ROBOTS') }

  def index
    sitemaps = [sitemap_groups_url(format: :xml)]
    topic_pages.times { |i| sitemaps << sitemap_topics_url(page: i + 1, format: :xml) }
    render xml: sitemap_index(sitemaps)
  end

  def groups
    rows = Group.visible_to_public.where.not(key: nil).pluck(:handle, :key, :name, :updated_at).map do |handle, key, name, updated_at|
      url = handle.present? ? group_handle_url(handle, format: nil) : group_url(key, slug: name.to_s.parameterize, format: nil)
      [url, updated_at]
    end
    render xml: urlset(rows)
  end

  def topics
    page = params[:page].to_i
    return head :not_found unless page.between?(1, topic_pages)

    rows = public_topics.order('topics.id').offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
      .pluck(:topicable_type, 'discussions.key', 'discussions.title', 'polls.key', 'polls.title', 'topics.last_activity_at')
      .map do |type, discussion_key, discussion_title, poll_key, poll_title, last_activity_at|
        url = if type == 'Poll'
          poll_url(poll_key, slug: poll_title.to_s.parameterize, format: nil)
        else
          discussion_url(discussion_key, slug: discussion_title.to_s.parameterize, format: nil)
        end
        [url, last_activity_at]
      end
    render xml: urlset(rows)
  end

  private

  def public_topics
    Topic.joins_groups.joins_topicables
      .where(private: false).not_discarded.group_kept.group_enabled
      .where('discussions.id IS NOT NULL OR polls.id IS NOT NULL')
  end

  def topic_pages
    @topic_pages ||= (public_topics.count.to_f / PAGE_SIZE).ceil
  end

  def sitemap_index(urls)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.sitemapindex(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
      urls.each { |url| xml.sitemap { xml.loc url } }
    end
  end

  def urlset(rows)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
      rows.each do |url, lastmod|
        xml.url do
          xml.loc url
          xml.lastmod lastmod.iso8601 if lastmod
        end
      end
    end
  end
end
