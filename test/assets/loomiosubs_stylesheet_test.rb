require 'test_helper'

class LoomiosubsStylesheetTest < ActiveSupport::TestCase
  test "styles the subscription buttons with the configured theme" do
    css = Rails.application.assets.find_asset("loomiosubs.css").to_s

    assert_includes css, ".btn--ink"
    assert_includes css, AppConfig.theme[:primary_color]
    assert_includes css, AppConfig.theme[:accent_color]
    refute_includes css, "#00BDD4"
    refute_includes css, "#F08B00"
  end
end
