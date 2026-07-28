require 'test_helper'

class ManifestControllerTest < ActionController::TestCase
  test "responds with a manifest.json" do
    get :show, format: :json
    json = JSON.parse(response.body)
    assert_equal AppConfig.theme[:site_name], json['name']
    assert_equal 'standalone', json['display']
    assert_equal '#F5C401', json['background_color']
    assert_equal '#0070E0', json['theme_color']
    assert_equal %w[192x192 512x512], json['icons'].pluck('sizes')
    assert json['icons'].all? { |icon| icon['src'].end_with?("/brand/icon-yellow-on-white-#{icon['sizes'].split('x').first}.png") }
  end
end
