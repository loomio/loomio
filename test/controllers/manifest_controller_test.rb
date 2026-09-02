require 'test_helper'

class ManifestControllerTest < ActionController::TestCase
  CONFIG_ENV_KEYS = %w[
    SITE_NAME
    SITE_SHORT_NAME
    THEME_ICON_SRC
    THEME_ICON_192_SRC
    THEME_ICON_512_SRC
    THEME_ICON_MASKABLE_192_SRC
    THEME_ICON_MASKABLE_512_SRC
  ].freeze

  setup do
    @config_env = ENV.to_h.slice(*CONFIG_ENV_KEYS)
    CONFIG_ENV_KEYS.each { |key| ENV.delete(key) }
  end

  teardown do
    CONFIG_ENV_KEYS.each { |key| ENV.delete(key) }
    @config_env.each { |key, value| ENV[key] = value }
  end

  test "responds with a complete web app manifest" do
    get :show, format: :json
    json = JSON.parse(response.body)

    assert_equal 'application/manifest+json', response.media_type
    assert_equal '/', json['id']
    assert_equal '/', json['scope']
    assert_equal AppConfig.theme[:site_name], json['name']
    assert_equal AppConfig.theme[:site_name], json['short_name']
    assert_equal AppConfig.theme[:site_description], json['description']
    assert_equal 'standalone', json['display']
    assert_equal '/dashboard', json['start_url']
    assert_equal AppConfig.theme[:brand_colors][:white], json['background_color']
    assert_equal AppConfig.theme[:primary_color], json['theme_color']
    refute json.key?('orientation')

    icons_any = json['icons'].select { |icon| icon['purpose'] == 'any' }
    icons_maskable = json['icons'].select { |icon| icon['purpose'] == 'maskable' }

    assert_equal %w[192x192 512x512], icons_any.pluck('sizes')
    assert_equal %w[192x192 512x512], icons_maskable.pluck('sizes')
    assert_equal %w[image/png image/png], icons_any.pluck('type')
    assert_equal %w[image/png image/png], icons_maskable.pluck('type')
    assert_equal %w[/brand/icon-yellow-on-white-192.png /brand/icon-yellow-on-white-512.png], icon_paths(icons_any)
    assert_equal %w[/brand/icon-maskable-192.png /brand/icon-maskable-512.png], icon_paths(icons_maskable)
  end

  test "uses configured short name and safely constructs configured icon URLs" do
    ENV['SITE_NAME'] = 'Example Community'
    ENV['SITE_SHORT_NAME'] = 'Example'
    ENV['THEME_ICON_192_SRC'] = 'https://cdn.example.com/icons/app.svg?version=1'
    ENV['THEME_ICON_512_SRC'] = '/custom/app-512.webp'

    get :show, format: :json
    json = JSON.parse(response.body)
    icons_any = json['icons'].select { |icon| icon['purpose'] == 'any' }
    icons_maskable = json['icons'].select { |icon| icon['purpose'] == 'maskable' }

    assert_equal 'Example Community', json['name']
    assert_equal 'Example', json['short_name']
    assert_equal 'https://cdn.example.com/icons/app.svg?version=1', icons_any.first['src']
    assert_equal 'image/svg+xml', icons_any.first['type']
    assert URI.parse(icons_any.second['src']).absolute?
    assert_equal '/custom/app-512.webp', URI.parse(icons_any.second['src']).path
    assert_equal 'image/webp', icons_any.second['type']
    assert_empty icons_maskable
  end

  private

  def icon_paths(icons)
    icons.pluck('src').map { |src| URI.parse(src).path }
  end
end
