require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @allow_robots = ENV['ALLOW_ROBOTS']
    @loomio_managed_server = ENV['LOOMIO_MANAGED_SERVER']
  end

  teardown do
    ENV['ALLOW_ROBOTS'] = @allow_robots
    ENV['LOOMIO_MANAGED_SERVER'] = @loomio_managed_server
  end

  test "adds a noindex header when robots are not allowed" do
    ENV.delete('ALLOW_ROBOTS')

    get :index

    assert_equal 'noindex', response.headers['X-Robots-Tag']
    assert_select "#loading-placeholder footer a[href='/about-loomio']"
    assert_includes response.body, "v#{Version.current}"
  end

  test "allows indexing on configured self-hosted installations" do
    ENV['ALLOW_ROBOTS'] = '1'

    get :index

    assert_nil response.headers['X-Robots-Tag']
  end

  test "does not allow indexing the about Loomio page on private installations" do
    ENV.delete('ALLOW_ROBOTS')

    get :about_loomio

    assert_response :success
    assert_equal 'noindex', response.headers['X-Robots-Tag']
    assert_select "html[lang='en']"
    assert_select "meta[name=description]"
    assert_select "meta[property='og:url'][content$='/about-loomio']"
    assert_select "link[rel=canonical][href$='/about-loomio']"
    assert_select "h1", "Loomio is a collaborative decision-making tool"
    assert_select "img[src*='logo']", count: 1
    assert_includes response.body, "cohousing communities"
    assert_includes response.body, "ecovillages"
    assert_select "a[href='https://www.loomio.com']"
    assert_select "script[type='application/ld+json']", /SoftwareApplication/
    assert_includes response.body, "This is an independently operated Loomio server"
    refute_includes response.body, "Powered by Loomio"
    refute_includes response.body, "v#{Version.current}"
  end

  test "omits the independent server disclaimer on Loomio-managed servers" do
    ENV['LOOMIO_MANAGED_SERVER'] = '1'

    get :about_loomio

    assert_response :success
    refute_includes response.body, "This is an independently operated Loomio server"
  end
end
