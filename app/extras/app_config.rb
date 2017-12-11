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
  )

  CONFIG_FILES.each do |config|
    define_singleton_method(config) do
      instance_variable_get(:"@#{config}") ||
      instance_variable_set(:"@#{config}", YAML.load_file(Rails.root.join("config", "#{config}.yml")))
    end
  end

  def self.poll_types
    poll_templates.keys - ENV['FEATURES_DISABLE_POLL_TYPES'].to_s.split(' ')
  end

  def self.theme
    {
      site_name:                         ENV.fetch('SITE_NAME',                     'Loomio'),
      icon_src:                          ENV.fetch('THEME_ICON_SRC',                '/theme/icon.png'),
      icon32_src:                        ENV.fetch('THEME_ICON32_SRC',              '/theme/icon32.png'),
      icon48_src:                        ENV.fetch('THEME_ICON48_SRC',              '/theme/icon48.png'),
      icon128_src:                       ENV.fetch('THEME_ICON128_SRC',             '/theme/icon128.png'),
      icon144_src:                       ENV.fetch('THEME_ICON144_SRC',             '/theme/icon144.png'),
      icon192_src:                       ENV.fetch('THEME_ICON192_SRC',             '/theme/icon192.png'),
      icon512_src:                       ENV.fetch('THEME_ICON512_SRC',             '/theme/icon512.png'),
      app_logo_src:                      ENV.fetch('THEME_APP_LOGO_SRC',            '/theme/logo.svg'),
      default_group_logo_src:            ENV.fetch('THEME_DEFAULT_GROUP_LOGO_SRC',  '/theme/default_group_logo.png'),
      default_group_cover_src:           ENV.fetch('THEME_DEFAULT_GROUP_COVER_SRC', '/theme/default_group_cover.png'),

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
      warn_palette:                      ENV.fetch('THEME_WARN_PALETTE',            'cyan'),
      primary_palette_config: JSON.parse(ENV.fetch('THEME_PRIMARY_PALETTE_CONFIG',  '{"default": "400"}')),
      accent_palette_config:  JSON.parse(ENV.fetch('THEME_ACCENT_PALETTE_CONFIG',   '{"default": "500"}')),
      warn_palette_config:    JSON.parse(ENV.fetch('THEME_WARN_PALETTE_CONFIG',     '{}')),
      custom_primary_palette:  json_parse_or_false('THEME_CUSTOM_PRIMARY_PALETTE'),
      custom_accent_palette:   json_parse_or_false('THEME_CUSTOM_ACCENT_PALETTE'),
      custom_warn_palette:     json_parse_or_false('THEME_CUSTOM_WARN_PALETTE')
    }
   end

   def self.features
     {
       create_user:                !ENV['FEATURES_DISABLE_CREATE_USER'],
       create_group:               !ENV['FEATURES_DISABLE_CREATE_GROUP'],
       public_groups:              !ENV['FEATURES_DISABLE_PUBLIC_GROUPS'],
       help_link:                  !ENV['FEATURES_DISABLE_HELP_LINK'],
       nested_comments_for_all:    ENV.fetch('FEATURES_NESTED_COMMENTS_FOR_ALL',    false),
       default_thread_render_mode: ENV.fetch('FEATURES_DEFAULT_THREAD_RENDER_MODE', 'chronological')
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
