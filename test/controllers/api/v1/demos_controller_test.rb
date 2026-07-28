require 'test_helper'

class Api::V1::DemosControllerTest < ActionController::TestCase
  test "clone is rate limited per user" do
    sign_in users(:user)

    ThrottleService.stub(:can?, false) do
      DemoService.stub(:take_demo, ->(*) { flunk('rate-limited requests must not clone a demo') }) do
        post :clone
      end
    end

    assert_response :too_many_requests
  end
end
