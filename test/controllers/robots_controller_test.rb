require 'test_helper'

class RobotsControllerTest < ActionController::TestCase
  setup do
    @allow_robots = ENV['ALLOW_ROBOTS']
  end

  teardown do
    ENV['ALLOW_ROBOTS'] = @allow_robots
  end

  test "disallows robots by default" do
    ENV.delete('ALLOW_ROBOTS')

    get :show, format: :text

    assert_includes response.body, 'Disallow: /'
  end

  test "allows robots on configured self-hosted installations" do
    ENV['ALLOW_ROBOTS'] = '1'

    get :show, format: :text

    assert_includes response.body, 'Allow: /'
  end
end
