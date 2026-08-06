require 'test_helper'

class LoomiosubsStylesheetTest < ActiveSupport::TestCase
  test "styles the subscription buttons with the configured theme" do
    css = Rails.root.join("app/assets/stylesheets/loomiosubs.css").read

    assert_includes css, ".btn--ink"
    assert_match(/\.price-box\s*\{[^}]*border:\s*2px solid var\(--loomio-primary-color\)/m, css)
    assert_match(/\.ribbon-grey[^}]*background:\s*var\(--loomio-primary-color\)/m, css)
    refute_includes css, "#00BDD4"
    refute_includes css, "#F08B00"
  end
end
