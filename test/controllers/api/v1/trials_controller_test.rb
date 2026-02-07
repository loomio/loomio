require 'test_helper'

class Api::V1::TrialsControllerTest < ActionController::TestCase
  test "invalid email returns error" do
    post :create, params: {
      user_email: "invalid_email",
      user_name: "normal name"
    }
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"]["user_email"], "Not a valid email"
  end

  test "existing email returns error" do
    User.create!(email: "verified@example.com", email_verified: true)
    post :create, params: {
      user_email: "verified@example.com",
      user_name: "normal name"
    }
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["errors"]["user_email"], "Email address already exists. Please sign in to continue."
  end

  test "creates new user and group and sends login email" do
    post :create, params: {
      user_name: "Jimmy",
      user_email: "jimmy@example.com",
      group_name: "Jim group",
      group_description: "Make decisions",
      group_category: "boards",
      group_how_did_you_hear_about_loomio: "I work there",
      user_email_newsletter: true,
      user_legal_accepted: true
    }
    assert_response :success
    
    user = User.find_by(email: 'jimmy@example.com')
    assert_equal "Jimmy", user.name
    assert user.email_newsletter
    
    group = user.adminable_groups.first
    assert_equal "/#{group.handle}", JSON.parse(response.body)['group_path']
    assert_equal "Jim group", group.name
    assert_equal "jim-group", group.handle
    assert_includes group.description, "Make decisions"
    assert_equal "boards", group.category
    assert_equal "I work there", group.info['how_did_you_hear_about_loomio']
  end
end
