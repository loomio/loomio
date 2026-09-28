require 'test_helper'

class Api::V1::DemosControllerTest < ActionController::TestCase
  setup do
    @loomio_disable_demo_groups = ENV["LOOMIO_DISABLE_DEMO_GROUPS"]
    @canonical_host = ENV["CANONICAL_HOST"]
    ENV.delete("LOOMIO_DISABLE_DEMO_GROUPS")
    ENV["CANONICAL_HOST"] = "loomio.eu"
  end

  teardown do
    ENV["LOOMIO_DISABLE_DEMO_GROUPS"] = @loomio_disable_demo_groups
    ENV["CANONICAL_HOST"] = @canonical_host
  end

  test "clone is rate limited per user" do
    sign_in users(:user)

    ThrottleService.stub(:can?, false) do
      DemoService.stub(:take_demo, ->(*) { flunk('rate-limited requests must not clone a demo') }) do
        post :clone
      end
    end

    assert_response :too_many_requests
  end

  test "clone requires a signed-in user" do
    DemoService.stub(:take_demo, ->(*) { flunk("signed-out requests must not claim a demo") }) do
      post :clone
    end

    assert_response :unauthorized
  end

  test "clone provisions and returns a demo group" do
    user = users(:user)
    group = groups(:group)
    sign_in user

    assert_enqueued_with(job: RefillDemoQueueWorker) do
      DemoService.stub(:take_demo, ->(actor) { assert_equal user, actor; group }) do
        post :clone
      end
    end

    assert_response :success
    assert_equal group.id, response.parsed_body.fetch("groups").first.fetch("id")
  end

  test "clone is unavailable when demo groups are disabled" do
    ENV["LOOMIO_DISABLE_DEMO_GROUPS"] = "1"
    sign_in users(:user)

    DemoService.stub(:take_demo, ->(*) { flunk("disabled demos must not provision a group") }) do
      post :clone
    end

    assert_response :not_found
  end

  test "demo groups are advertised on all configured hosts unless disabled" do
    assert AppConfig.app_features[:demos]

    ENV["CANONICAL_HOST"] = "private.example.org"
    assert AppConfig.app_features[:demos]

    ENV["CANONICAL_HOST"] = "loomio.com"
    assert AppConfig.app_features[:demos]

    ENV["CANONICAL_HOST"] = "www.loomio.com"
    assert AppConfig.app_features[:demos]

    ENV["LOOMIO_DISABLE_DEMO_GROUPS"] = "1"
    refute AppConfig.app_features[:demos]
  end
end
