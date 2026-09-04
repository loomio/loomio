require 'test_helper'

class Api::V1::DemosControllerTest < ActionController::TestCase
  setup do
    @features_demo_groups = ENV["FEATURES_DEMO_GROUPS"]
    ENV["FEATURES_DEMO_GROUPS"] = "enabled"
  end

  teardown do
    ENV["FEATURES_DEMO_GROUPS"] = @features_demo_groups
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

  test "clone provisions and returns a demo group" do
    user = users(:user)
    group = groups(:group)
    sign_in user

    DemoService.stub(:take_demo, ->(actor) { assert_equal user, actor; group }) do
      post :clone
    end

    assert_response :success
    assert_equal group.id, response.parsed_body.fetch("groups").first.fetch("id")
  end

  test "clone is unavailable when demo groups are disabled" do
    ENV.delete("FEATURES_DEMO_GROUPS")
    sign_in users(:user)

    DemoService.stub(:take_demo, ->(*) { flunk("disabled demos must not provision a group") }) do
      post :clone
    end

    assert_response :not_found
  end

  test "demo groups are advertised when enabled" do
    assert AppConfig.app_features[:demos]

    ENV.delete("FEATURES_DEMO_GROUPS")

    refute AppConfig.app_features[:demos]
  end
end
