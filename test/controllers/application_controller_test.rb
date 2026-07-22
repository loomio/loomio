require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    @allow_robots = ENV['ALLOW_ROBOTS']
  end

  teardown do
    ENV['ALLOW_ROBOTS'] = @allow_robots
  end

  test "adds a noindex header when robots are not allowed" do
    ENV.delete('ALLOW_ROBOTS')

    get :index

    assert_equal 'noindex', response.headers['X-Robots-Tag']
  end

  test "allows indexing on configured self-hosted installations" do
    ENV['ALLOW_ROBOTS'] = '1'

    get :index

    assert_nil response.headers['X-Robots-Tag']
  end
end
