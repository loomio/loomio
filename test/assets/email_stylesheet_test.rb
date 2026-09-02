require 'test_helper'

class EmailStylesheetTest < ActiveSupport::TestCase
  test "contains only the focused email styles" do
    css = Rails.root.join("app/assets/stylesheets/email.css").read

    assert_operator css.bytesize, :<, 10_000
    assert_match(/border-left:\s*4px solid currentColor/, css)
    refute_includes css, ".elevation-24"
    refute_includes css, ".theme--light.v-card"
    refute_includes css, ".v-layout-table"
    refute_includes css, ".v-table"
    refute_match(/color:\s*#666/, css)
  end
end
