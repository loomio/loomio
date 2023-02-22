class AppConfig
  CONFIG_FILES = %w(
    webhook_event_kinds
    colors
    durations
    emojis
    plugins
    poll_types
    providers
    timezones
    notifications
    doctypes
    locales
    moment_locales
    group_features
    translate_languages
  )

  BANNED_CHARS = %(\\s:,;'"`<>)
  EMAIL_REGEX  = /[^#{BANNED_CHARS}]+?@[^#{BANNED_CHARS}]+\.[^#{BANNED_CHARS}]+/
  URL_REGEX    = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/

  CONFIG_FILES.each do |config|
    define_singleton_method(config) do
      instance_variable_get(:"@#{config}") ||
      instance_variable_set(:"@#{config}", YAML.load_file(Rails.root.join("config", "#{config}.yml")))
    end
  end

  def self.release
    @release ||= begin
      (`git rev-parse HEAD`.strip.presence || File.mtime("app").to_i.to_s)
    end
  end

  def self.image_regex
    doctypes.detect { |type| type['name'] == 'image' }['regex']
  end

  def self.theme

    brand_colors = {
      gold: "#DCA034",
      ink: "#293C4A",
      wellington: "#7F9EA0",
      sunset: "#E4C2B9",
      sky: "#658AE7",
      rock: "#C77C3B",
      white: "#FFFFFF"
    }

    # here are some useful variations on these colours
    # https://maketintsandshades.com/#DCA034,293C4A,7F9EA0,E4C2B9,658AE7,C77C3B

    logo_color = :gold

    {
      brand_colors:                      brand_colors,
      site_name:                         ENV.fetch('SITE_NAME',                     'Loomio'),
      channels_uri:                      ENV.fetch('CHANNELS_URI',                  'ws://localhost:5000'),
      terms_url:                         ENV['TERMS_URL'],
      privacy_url:                       ENV['PRIVACY_URL'],
      canonical_host:                    ENV['CANONICAL_HOST'],
      reply_hostname:                    ENV['REPLY_HOSTNAME'],
      help_url:                          ENV.fetch('HELP_URL',                      'https://help.loomio.com/'),
      icon_src:                          ENV.fetch('THEME_ICON_SRC',                "/brand/icon_#{logo_color}_150h.png"),
      app_logo_src:                      ENV.fetch('THEME_APP_LOGO_SRC',            "/brand/logo_#{logo_color}.svg"),
      apple_touch_src:                   ENV.fetch('APPLE_TOUCH_SRC',               "/brand/touch_icon_gold.png"),
      default_group_cover_src:           ENV.fetch('THEME_DEFAULT_GROUP_COVER_SRC', '/theme/default_group_cover.png'),

      # used in emails
      email_header_logo_src:             ENV.fetch('THEME_EMAIL_HEADER_LOGO_SRC',   "/brand/logo_#{logo_color}_96h.png"),
      email_footer_logo_src:             ENV.fetch('THEME_EMAIL_FOOTER_LOGO_SRC',   "/brand/logo_#{logo_color}_48h.png"),
      primary_color:                     ENV.fetch('THEME_PRIMARY_COLOR',           brand_colors[:sky]),
      accent_color:                      ENV.fetch('THEME_ACCENT_COLOR',            brand_colors[:gold]),
      text_on_primary_color:             ENV.fetch('THEME_TEXT_ON_PRIMARY_COLOR',   '#ffffff'),
      text_on_accent_color:              ENV.fetch('THEME_TEXT_ON_ACCENT_COLOR',    '#ffffff'),

      vuetify: {
        primary: ENV.fetch('THEME_COLOR_PRIMARY', brand_colors[:sky]),
        secondary: ENV.fetch('THEME_COLOR_SECONDARY', brand_colors[:sunset]),
        accent: ENV.fetch('THEME_COLOR_ACCENT', brand_colors[:gold]),
        error: ENV.fetch('THEME_COLOR_ERROR', nil),
        warning: ENV.fetch('THEME_COLOR_WARNING', nil),
        info: ENV.fetch('THEME_COLOR_INFO', brand_colors[:sky]),
        success: ENV.fetch('THEME_COLOR_SUCCESS', nil),
        anchor: ENV.fetch('THEME_COLOR_ANCHOR', brand_colors[:sky])
      }
    }
  end

  def self.app_features
    {
      env: Rails.env,
      subscriptions:              !!ENV.fetch('CHARGIFY_API_KEY', false),
      demos:                      ENV.fetch('FEATURES_DEMO_GROUPS', false),
      trials:                     ENV.fetch('FEATURES_TRIALS', false),
      email_login:                !ENV['FEATURES_DISABLE_EMAIL_LOGIN'],
      create_user:                !ENV['FEATURES_DISABLE_CREATE_USER'],
      create_group:               !ENV['FEATURES_DISABLE_CREATE_GROUP'],
      public_groups:              !ENV['FEATURES_DISABLE_PUBLIC_GROUPS'],
      help_link:                  !ENV['FEATURES_DISABLE_HELP_LINK'],
      example_content:            !ENV['FEATURES_DISABLE_EXAMPLE_CONTENT'],
      explore_public_groups:      ENV.fetch('FEATURES_EXPLORE_PUBLIC_GROUPS', false),
      template_gallery:           ENV.fetch('FEATURES_TEMPLATE_GALLERY', false),
      show_contact:               ENV.fetch('FEATURES_SHOW_CONTACT', false),
      thread_page_v3:             ENV.fetch('FEATURES_THREAD_PAGE_V3', false),
      show_contact_consent:       ENV.fetch('FEATURES_SHOW_CONTACT_CONSENT', false),
      sentry_sample_rate:         ENV.fetch('SENTRY_SAMPLE_RATE', 0.1).to_f,
    }
  end

  def self.json_parse_or_false(name)
    if ENV[name]
      JSON.parse(ENV[name])
    else
      false
    end
  end
end
