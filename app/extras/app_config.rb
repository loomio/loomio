class AppConfig
  CONFIG_FILES = %w[
    webhook_event_kinds
    colors
    emojis
    poll_types
    poll_templates
    discussion_templates
    providers
    doctypes
    locales
  ]

  BANNED_CHARS = %(\\s:,;\\[\\]'"`<>)
  EMAIL_REGEX  = /[^#{BANNED_CHARS}]+?@[^#{BANNED_CHARS}]+/
  URL_REGEX    = %r{https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)}

  CONFIG_FILES.each do |config|
    define_singleton_method(config) do
      instance_variable_get(:"@#{config}") ||
        instance_variable_set(:"@#{config}", YAML.load_file(Rails.root.join("config", "#{config}.yml")))
    end
  end

  def self.release
    @release ||= `git rev-parse HEAD`.strip.presence || File.mtime("app").to_i.to_s
  end

  def self.image_regex
    doctypes.detect { |type| type['name'] == 'image' }['regex']
  end

  def self.theme
    brand_colors = {
      yellow50: "#FFF7E0",
      yellow425: "#F5C401",
      blue50: "#EBF4FF",
      blue400: "#1F87FF",
      blue500: "#0070E0",
      green50: "#EDFAF3",
      green400: "#22B866",
      green600: "#0D7A3C",
      red50: "#FEF1F1",
      red400: "#F05252",
      red500: "#D43030",
      grey50: "#F5F5F5",
      grey100: "#E8E8E8",
      grey700: "#212121",
      grey800: "#121212",
      white: "#FFFFFF"
    }
    default_hocuspocus_url = Rails.env.production? ? "wss://hocuspocus.#{ENV['CANONICAL_HOST']}" : "ws://localhost:4444"

    light = {
      background: ENV['THEME_LIGHT_BACKGROUND'],
      surface: ENV['THEME_LIGHT_SURFACE'],
      appbar: ENV['THEME_LIGHT_APPBAR'],
      drawer: ENV['THEME_LIGHT_DRAWER'],
      primary: ENV['THEME_LIGHT_PRIMARY'],
      accent: ENV['THEME_LIGHT_ACCENT'],
      anchor: ENV['THEME_LIGHT_ANCHOR'],
      info: ENV['THEME_LIGHT_INFO'],
      success: ENV['THEME_LIGHT_SUCCESS'],
      error: ENV['THEME_LIGHT_ERROR'],
      warning: ENV['THEME_LIGHT_WARNING']
    }

    dark = {
      background: ENV['THEME_DARK_BACKGROUND'],
      surface: ENV['THEME_DARK_SURFACE'],
      appbar: ENV['THEME_DARK_APPBAR'],
      drawer: ENV['THEME_DARK_DRAWER'],
      primary: ENV['THEME_DARK_PRIMARY'],
      accent: ENV['THEME_DARK_ACCENT'],
      anchor: ENV['THEME_DARK_ANCHOR'],
      info: ENV['THEME_DARK_INFO'],
      success: ENV['THEME_DARK_SUCCESS'],
      error: ENV['THEME_DARK_ERROR'],
      warning: ENV['THEME_DARK_WARNING']
    }

    {
      brand_colors: brand_colors,
      site_name: ENV.fetch('SITE_NAME', 'Loomio'),
      site_description: ENV.fetch('SITE_DESCRIPTION', I18n.t('email.loomio_app_description')),
      hocuspocus_url: ENV.fetch('HOCUSPOCUS_URL', default_hocuspocus_url),
      terms_url: ENV['TERMS_URL'],
      privacy_url: ENV['PRIVACY_URL'],
      canonical_host: ENV['CANONICAL_HOST'],
      reply_hostname: ENV['REPLY_HOSTNAME'],
      help_url: ENV.fetch('HELP_URL', 'https://help.loomio.com/'),
      icon_src: ENV.fetch('THEME_ICON_SRC', "/brand/favicon-yellow-on-transparent.svg"),
      favicon16_src: ENV.fetch('THEME_FAVICON_16_SRC', ENV.fetch('THEME_ICON_SRC', "/brand/favicon-yellow-on-transparent-16.png")),
      favicon32_src: ENV.fetch('THEME_FAVICON_32_SRC', ENV.fetch('THEME_ICON_SRC', "/brand/favicon-yellow-on-transparent-32.png")),
      touch_icon_src: ENV.fetch('THEME_TOUCH_ICON_SRC', ENV.fetch('THEME_ICON_SRC', "/brand/icon-yellow-on-white-256.png")),
      icon192_src: ENV.fetch('THEME_ICON_192_SRC', ENV.fetch('THEME_ICON_SRC', "/brand/icon-yellow-on-white-192.png")),
      icon512_src: ENV.fetch('THEME_ICON_512_SRC', ENV.fetch('THEME_ICON_SRC', "/brand/icon-yellow-on-white-512.png")),
      app_logo_src: ENV.fetch('THEME_APP_LOGO_SRC', "/brand/logo-current-color.svg"),
      saml_login_provider_name: ENV.fetch('SAML_LOGIN_PROVIDER_NAME', 'SAML'),
      oauth_login_provider_name: ENV.fetch('OAUTH_LOGIN_PROVIDER_NAME', 'OAUTH'),
      # used in emails
      email_header_logo_src: ENV.fetch('THEME_EMAIL_HEADER_LOGO_SRC', "/brand/logo-yellow-96h.png"),
      email_footer_logo_src: ENV.fetch('THEME_EMAIL_FOOTER_LOGO_SRC', "/brand/logo-yellow-48h.png"),
      primary_color: ENV.fetch('THEME_PRIMARY_COLOR', brand_colors[:blue500]),
      accent_color: ENV.fetch('THEME_ACCENT_COLOR', brand_colors[:yellow425]),
      text_on_primary_color: ENV.fetch('THEME_TEXT_ON_PRIMARY_COLOR', '#ffffff'),
      text_on_accent_color: ENV.fetch('THEME_TEXT_ON_ACCENT_COLOR', brand_colors[:grey700]),
      default_invitation_message: ENV['THEME_DEFAULT_INVITATION_MESSAGE'],
      default_dark_theme: ENV.fetch('THEME_DEFAULT_DARK_THEME', 'dark'),
      default_light_theme: ENV.fetch('THEME_DEFAULT_LIGHT_THEME', 'light'),
      light: light,
      dark: dark
    }
  end

  def self.app_features
    {
      env: Rails.env,
      subscriptions: !!ENV.fetch('CHARGIFY_API_KEY', false),
      demos: ENV.fetch('FEATURES_DEMO_GROUPS', false),
      trials: ENV.fetch('FEATURES_TRIALS', false),
      trial_days: ENV.fetch('TRIAL_DAYS', nil),
      gray_sidebar_logo_in_dark_mode: ENV.fetch('FEATURES_GRAY_SIDEBAR_LOGO_IN_DARK_MODE', false),
      new_thread_button: !!ENV.fetch('FEATURES_NEW_THREAD_BUTTON', false),
      email_login: !ENV['FEATURES_DISABLE_EMAIL_LOGIN'],
      create_user: !ENV['FEATURES_DISABLE_CREATE_USER'],
      create_group: !ENV['FEATURES_DISABLE_CREATE_GROUP'],
      public_groups: !ENV['FEATURES_DISABLE_PUBLIC_GROUPS'],
      help_link: !ENV['FEATURES_DISABLE_HELP_LINK'],
      example_content: !ENV['FEATURES_DISABLE_EXAMPLE_CONTENT'],
      thread_from_mail: !ENV['FEATURES_DISABLE_THREAD_FROM_MAIL'],
      explore_public_groups: ENV.fetch('FEATURES_EXPLORE_PUBLIC_GROUPS', false),
      restrict_explore_to_signed_in_users: ENV.fetch('LOOMIO_RESTRICT_EXPLORE_TO_SIGNED_IN_USERS', false),
      template_gallery: ENV.fetch('FEATURES_TEMPLATE_GALLERY', false),
      show_contact: ENV.fetch('FEATURES_SHOW_CONTACT', false),
      show_contact_consent: ENV.fetch('FEATURES_SHOW_CONTACT_CONSENT', false),
      sso_disable_edit_profile: !!ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] || ActiveModel::Type::Boolean.new.cast(ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE']),
      sentry_sample_rate: ENV.fetch('SENTRY_SAMPLE_RATE', 0.1).to_f,
      hidden_poll_templates: [],
      transcription: TranscriptionService.available?,
      max_message_length: ENV.fetch('LMO_MAX_MESSAGE_LENGTH', 100000),
      verify_participants_admin_only: !!ENV['LOOMIO_VERIFY_PARTICIPANTS_ADMIN_ONLY']
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
