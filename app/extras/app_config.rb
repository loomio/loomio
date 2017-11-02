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
    locales
  )

  CONFIG_FILES.each do |config|
    define_singleton_method(config) do
      instance_variable_get(:"@#{config}") ||
      instance_variable_set(:"@#{config}", YAML.load_file(Rails.root.join("config", "#{config}.yml")))
    end
  end

  def self.theme
    {
      site_name:                         ENV.fetch('SITE_NAME',                     'Loomio'),
      icon_src:                          ENV.fetch('THEME_ICON_SRC',                '/theme/icon.png'),
      app_logo_src:                      ENV.fetch('THEME_APP_LOGO_SRC',            '/theme/logo.svg'),
      default_group_logo_src:            ENV.fetch('THEME_DEFAULT_GROUP_LOGO_SRC',  '/theme/default_group_logo.png'),
      default_group_cover_src:           ENV.fetch('THEME_DEFAULT_GROUP_COVER_SRC', '/theme/default_group_cover.png'),

      # used in emails
      email_header_logo_src:             ENV.fetch('THEME_EMAIL_HEADER_LOGO_SRC',   '/theme/logo_128h.png'),
      email_footer_logo_src:             ENV.fetch('THEME_EMAIL_FOOTER_LOGO_SRC',   '/theme/logo_64h.png'),
      primary_color:                     ENV.fetch('THEME_PRIMARY_COLOR',           'rgb(255,167,38)'),
      accent_color:                      ENV.fetch('THEME_ACCENT_COLOR',            'rgb(0,188,212)'),
      text_on_primary_color:             ENV.fetch('THEME_TEXT_ON_PRIMARY_COLOR',   'rgb(255,255,255)'),
      text_on_accent_color:              ENV.fetch('THEME_TEXT_ON_ACCENT_COLOR',    'rgb(255,255,255)'),

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
       create_user:   !ENV['FEATURES_DISABLE_CREATE_USER'],
       create_group:  !ENV['FEATURES_DISABLE_CREATE_GROUP'],
       public_groups: !ENV['FEATURES_DISABLE_PUBLIC_GROUPS'],
       help_link:     !ENV['FEATURES_DISABLE_HELP_LINK']
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
