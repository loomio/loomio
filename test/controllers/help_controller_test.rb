require 'test_helper'

class HelpControllerTest < ActionController::TestCase
  test "api help documents thread reads and the facilitator skill" do
    sign_in users(:user)

    get :api2

    assert_response :success
    assert_includes response.body, "/api/b2/threads"
    assert_includes response.body, "/markdown"
    assert_includes response.body, "/skills/loomio-facilitator/SKILL.md"
  end

  test "whats_new renders entries from the changelog directory" do
    latest_entry = Dir.glob(Rails.root.join("docs", "user_manual", "changelog", "*.md")).sort.last
    heading = File.read(latest_entry).lines.first.delete_prefix("# ").strip

    get :whats_new

    assert_response :success
    assert_includes response.body, heading
  end
end
