require 'test_helper'

# What crawlers and link previews receive: server-rendered pages for threads,
# polls and groups, with metadata, structured data, pagination, robots.txt and
# a sitemap. People are served the app; exports reuse the same pages.
class CrawlerPagesTest < ActionDispatch::IntegrationTest
  BOT = { 'User-Agent' => 'Googlebot' }.freeze

  setup do
    @group = groups(:public_group)
    @discussion = discussions(:public_discussion)
    @admin = users(:admin)
    @group.add_admin!(@admin) unless @group.admins.include?(@admin)
    @allow_robots = ENV['ALLOW_ROBOTS']
  end

  teardown do
    @allow_robots.nil? ? ENV.delete('ALLOW_ROBOTS') : ENV['ALLOW_ROBOTS'] = @allow_robots
  end

  def poll_params(**extra)
    { title: 'Public question', details: 'Which **option**?', poll_type: 'proposal',
      poll_option_names: %w[Agree Disagree], closing_at: 3.days.from_now, group_id: @group.id }.merge(extra)
  end

  def standalone_poll
    @standalone_poll ||= PollService.create(params: poll_params, actor: @admin).tap do |poll|
      poll.topic.update!(private: false)
    end
  end

  def page
    Nokogiri::HTML5(response.body, max_errors: 50)
  end

  def json_ld
    JSON.parse(page.at_css('script[type="application/ld+json"]').text)
  end

  def add_comments(count)
    count.times do |i|
      comment = Comment.create!(body: "Reply #{i}", body_format: 'md', parent: @discussion, author: @admin)
      comment.topic_items.create!(kind: :new_comment, user: @admin, topic: @discussion.topic, created_at: comment.created_at)
    end
  end

  test 'a standalone poll page shows the poll once, as an article with its own canonical URL' do
    get poll_path(standalone_poll), headers: BOT

    assert_response :success
    assert_equal 1, page.css('h1').size
    assert_equal 'Public question', page.at_css('h1').text
    assert_empty page.css('.poll-common-card__title')
    assert_includes page.at_css('.poll-common-details-panel__details').text, 'Which option?'
    assert_match %r{/p/#{standalone_poll.key}}, page.at_css('link[rel=canonical]')['href']
    assert_equal 'article', page.at_css('meta[property="og:type"]')['content']
    assert_equal 'DiscussionForumPosting', json_ld['@type']
  end

  test 'a poll in a thread points crawlers at the thread' do
    poll = PollService.create(params: poll_params(topic_id: @discussion.topic_id), actor: @admin)

    get poll_path(poll), headers: BOT

    assert_response :success
    assert_equal @discussion.title, page.at_css('h1').text
    assert_match %r{/d/#{@discussion.key}}, page.at_css('link[rel=canonical]')['href']
  end

  test 'people still get the app on a poll page' do
    get poll_path(standalone_poll), headers: { 'User-Agent' => 'Mozilla/5.0 (Macintosh) Firefox/140.0' }

    assert_response :success
    assert page.at_css('#loading-placeholder')
    assert_nil page.at_css('.context-panel')
  end

  test 'crawlers page through every item on plain, indexable URLs' do
    add_comments(ApplicationController::BOT_PAGE_SIZE + 1)

    get discussion_path(@discussion), headers: BOT
    next_link = page.at_css('a[rel=next]')
    assert_equal '?offset=50', next_link['href']
    assert_nil page.at_css('meta[name=robots]')
    assert_no_match(/offset/, page.at_css('link[rel=canonical]')['href'])

    get "#{discussion_path(@discussion)}?offset=50", headers: BOT
    assert_match(/offset=50/, page.at_css('link[rel=canonical]')['href'])
    assert_equal '?', page.at_css('a[rel=prev]')['href']
    assert_nil page.at_css('a[rel=next]')
  end

  test 'exports keep their export links and stay out of search results' do
    add_comments(3)

    get "#{discussion_path(@discussion)}?export=1&limit=2"

    assert_equal 'noindex,follow', page.at_css('meta[name=robots]')['content']
    assert_equal 'next nofollow', page.at_css('a[href*="export=1"]')['rel']
    assert_nil page.at_css('script[type="application/ld+json"]')
  end

  test 'thread pages are valid HTML with unique ids and article metadata' do
    add_comments(2)
    PollService.create(params: poll_params(topic_id: @discussion.topic_id), actor: @admin)

    get discussion_path(@discussion), headers: BOT

    doc = page
    assert_empty doc.errors.map(&:to_s)
    ids = doc.css('[id]').map { |node| node['id'] }
    assert_equal ids, ids.uniq
    assert_equal "#{@discussion.title} | #{AppConfig.theme[:site_name]}", doc.at_css('title').text
    assert doc.at_css('meta[property="article:published_time"]')
    assert doc.at_css('time[datetime]')
    data = json_ld
    assert_equal @discussion.title, data['headline']
    assert_equal ['Reply 0', 'Reply 1'], data['comment'].map { |comment| comment['text'] }.last(2)
  end

  test 'link previews get absolute image URLs and a plain-text group excerpt' do
    @group.cover_photo.attach(io: File.open(Rails.root.join('public/brand/icon-yellow-on-white-256.png')), filename: 'cover.png')
    @group.update!(description: "First line\n\nSecond **line**", description_format: 'md')

    get group_path(@group), headers: BOT

    image = page.at_css('meta[property="og:image"]')['content']
    assert_match %r{\Ahttps?://}, image
    description = page.at_css('meta[name=description]')['content']
    assert_equal 'First line Second line', description
  end

  test 'group pages list public threads and standalone polls, public subgroups, and page through them' do
    standalone_poll
    subgroup = Group.create!(name: 'Open subgroup', parent: @group, is_visible_to_public: true, group_privacy: 'open')

    get group_path(@group), headers: BOT

    titles = page.css('.topic-preview__title').map(&:text)
    assert_includes titles, @discussion.title
    assert_includes titles, 'Public question'
    assert_includes page.css('.group-page__subgroups a').map(&:text), subgroup.name
    assert_empty page.css('.gruop-page')
    assert_nil page.at_css('a[rel=next]')

    stub_const(Views::Groups::Show, :PAGE_SIZE, 1) do
      get group_path(@group), headers: BOT
      assert_equal '?page=2', page.at_css('a[rel=next]')['href']
      get "#{group_path(@group)}?page=2", headers: BOT
      assert_match(/page=2/, page.at_css('link[rel=canonical]')['href'])
    end
  end

  test 'robots.txt keeps crawlers out of signed-in areas and points at the sitemap' do
    ENV['ALLOW_ROBOTS'] = '1'

    get '/robots'

    assert_includes response.body, "Disallow: /api/\n"
    assert_includes response.body, "Disallow: /dashboard\n"
    assert_match %r{^Sitemap: https?://.+/sitemap\.xml$}, response.body
  end

  test 'the sitemap lists public groups, threads and polls, and nothing private' do
    ENV['ALLOW_ROBOTS'] = '1'
    standalone_poll
    private_discussion = discussions(:discussion)

    get '/sitemap.xml'
    assert_response :success
    index = Nokogiri::XML(response.body).remove_namespaces!
    locs = index.xpath('//sitemap/loc').map(&:text)
    assert locs.any? { |loc| loc.end_with?('/sitemap/groups.xml') }
    assert locs.any? { |loc| loc.end_with?('/sitemap/topics/1.xml') }

    get '/sitemap/topics/1.xml'
    urls = Nokogiri::XML(response.body).remove_namespaces!.xpath('//url/loc').map(&:text)
    assert urls.any? { |url| url.include?("/d/#{@discussion.key}") }
    assert urls.any? { |url| url.include?("/p/#{standalone_poll.key}") }
    assert urls.none? { |url| url.include?("/d/#{private_discussion.key}") }
    assert urls.none? { |url| url.end_with?('.xml') }

    get '/sitemap/groups.xml'
    assert_includes response.body, "/#{@group.handle}"
  end

  test 'without ALLOW_ROBOTS, as on loomio.com, crawler pages are kept out of search results' do
    ENV.delete('ALLOW_ROBOTS')

    get discussion_path(@discussion), headers: BOT

    assert_response :success
    assert_equal 'noindex', response.headers['X-Robots-Tag']
  end

  test 'there is no sitemap where robots are disallowed' do
    ENV.delete('ALLOW_ROBOTS')

    get '/sitemap.xml'

    assert_response :not_found
  end

  test 'chatbot and webhook views do not inherit the web page base' do
    assert_not Views::Chatbot::Base <= Views::Application::Component
  end

  private

  def stub_const(klass, name, value)
    original = klass.const_get(name)
    klass.send(:remove_const, name)
    klass.const_set(name, value)
    yield
  ensure
    klass.send(:remove_const, name)
    klass.const_set(name, original)
  end
end
