require 'test_helper'

class EmailStylesheetTest < ActiveSupport::TestCase
  test "contains only the focused email styles and dark button overrides" do
    css = Rails.application.assets.find_asset("email.css").to_s

    assert_operator css.bytesize, :<, 8_000
    assert_match(/@media\s*\(prefers-color-scheme:\s*dark\)/, css)
    assert_includes css, ".base-mailer__button--primary"
    assert_match(/border-left:\s*4px solid currentColor/, css)
    refute_includes css, ".elevation-24"
    refute_includes css, ".theme--light.v-card"
    refute_match(/color:\s*#666/, css)
  end
end
