class AppConfig
  CONFIG_FILES = %w(
    colors
    durations
    emojis
    plugins
    poll_templates
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

  def self.image_regex
    doctypes.detect { |type| type['name'] == 'image' }['regex']
  end

  def self.poll_types
    poll_templates.keys - ENV['FEATURES_DISABLE_POLL_TYPES'].to_s.split(' ')
  end

  def self.theme
    {
      site_name:                         ENV.fetch('SITE_NAME',                     'Loomio'),
      terms_url:                         ENV['TERMS_URL'],
      privacy_url:                       ENV['PRIVACY_URL'],
      icon_src:                          ENV.fetch('THEME_ICON_SRC',                '/theme/icon.png'),
      app_logo_src:                      ENV.fetch('THEME_APP_LOGO_SRC',            '/theme/logo.svg'),
      default_group_cover_src:           ENV.fetch('THEME_DEFAULT_GROUP_COVER_SRC', '/theme/default_group_cover.png'),
      dont_notify_new_thread:            ENV['DONT_NOTIFY_NEW_THREAD'],

      # used in emails
      email_header_logo_src:             ENV.fetch('THEME_EMAIL_HEADER_LOGO_SRC',   '/theme/logo_128h.png'),
      email_footer_logo_src:             ENV.fetch('THEME_EMAIL_FOOTER_LOGO_SRC',   '/theme/logo_64h.png'),
      primary_color:                     ENV.fetch('THEME_PRIMARY_COLOR',           '#ffa726'),
      accent_color:                      ENV.fetch('THEME_ACCENT_COLOR',            '#00bcd4'),
      text_on_primary_color:             ENV.fetch('THEME_TEXT_ON_PRIMARY_COLOR',   '#ffffff'),
      text_on_accent_color:              ENV.fetch('THEME_TEXT_ON_ACCENT_COLOR',    '#ffffff'),

      # used in app
      primary_palette:                   ENV.fetch('THEME_PRIMARY_PALETTE',         'orange'),
      accent_palette:                    ENV.fetch('THEME_ACCENT_PALETTE',          'cyan'),
      warn_palette:                      ENV.fetch('THEME_WARN_PALETTE',            'red'),
      primary_palette_config: JSON.parse(ENV.fetch('THEME_PRIMARY_PALETTE_CONFIG',  '{"default": "400"}')),
      accent_palette_config:  JSON.parse(ENV.fetch('THEME_ACCENT_PALETTE_CONFIG',   '{"default": "500"}')),
      warn_palette_config:    JSON.parse(ENV.fetch('THEME_WARN_PALETTE_CONFIG',     '{}')),
      custom_primary_palette:  json_parse_or_false('THEME_CUSTOM_PRIMARY_PALETTE'),
      custom_accent_palette:   json_parse_or_false('THEME_CUSTOM_ACCENT_PALETTE'),
      custom_warn_palette:     json_parse_or_false('THEME_CUSTOM_WARN_PALETTE')
    }
  end

  def self.app_features
    {
      email_login:                !ENV['FEATURES_DISABLE_EMAIL_LOGIN'],
      create_user:                !ENV['FEATURES_DISABLE_CREATE_USER'],
      create_group:               !ENV['FEATURES_DISABLE_CREATE_GROUP'],
      public_groups:              !ENV['FEATURES_DISABLE_PUBLIC_GROUPS'],
      ahoy_tracking:              !ENV['FEATURES_DISABLE_AHOY_TRACKING'],
      help_link:                  !ENV['FEATURES_DISABLE_HELP_LINK'],
      example_content:            !ENV['FEATURES_DISABLE_EXAMPLE_CONTENT'],
      nested_comments:            ENV.fetch('FEATURES_NESTED_COMMENTS_FOR_ALL',    false),
      default_thread_render_mode: ENV.fetch('FEATURES_DEFAULT_THREAD_RENDER_MODE', 'chronological'),
      show_microsoft_card:        ENV.fetch('FEATURES_ENABLE_MICROSOFT_TEAMS',     false),
      show_contact_consent:       ENV.fetch('FEATURES_SHOW_CONTACT_CONSENT',       false)
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
