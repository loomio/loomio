require 'test_helper'

class ManifestControllerTest < ActionController::TestCase
  test "responds with a manifest.json" do
    get :show, format: :json
    json = JSON.parse(response.body)
    assert_equal AppConfig.theme[:site_name], json['name']
    assert_equal 'standalone', json['display']
  end
end
