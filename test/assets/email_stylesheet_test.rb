require 'test_helper'

class EmailStylesheetTest < ActiveSupport::TestCase
  test "contains only the focused email styles" do
    css = Rails.root.join("app/assets/stylesheets/vtfy/mailers.css").read
    css << Rails.root.join("app/assets/stylesheets/vtfy/email_utilities.css").read

    assert_operator css.bytesize, :<, 8_000
    assert_match(/border-left:\s*4px solid currentColor/, css)
    refute_includes css, ".elevation-24"
    refute_includes css, ".theme--light.v-card"
    refute_match(/color:\s*#666/, css)
  end
end
