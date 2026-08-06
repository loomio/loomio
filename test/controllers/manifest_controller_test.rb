require 'test_helper'

class ManifestControllerTest < ActionController::TestCase
  test "responds with a manifest.json" do
    get :show, format: :json
    json = JSON.parse(response.body)
    assert_equal AppConfig.theme[:site_name], json['name']
    assert_equal 'standalone', json['display']
    assert_equal AppConfig.theme[:brand_colors][:yellow425], json['background_color']
    assert_equal AppConfig.theme[:primary_color], json['theme_color']
    assert_equal %w[192x192 512x512], json['icons'].pluck('sizes')
    assert_equal [AppConfig.theme[:icon192_src], AppConfig.theme[:icon512_src]],
                 json['icons'].pluck('src').map { |src| URI.parse(src).path }
  end
end
