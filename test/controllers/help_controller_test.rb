require 'test_helper'

class HelpControllerTest < ActionController::TestCase
  test "whats_new renders entries from the changelog directory" do
    latest_entry = Dir.glob(Rails.root.join("docs", "user_manual", "changelog", "*.md")).sort.last
    heading = File.read(latest_entry).lines.first.delete_prefix("# ").strip

    get :whats_new

    assert_response :success
    assert_includes response.body, heading
  end
end
