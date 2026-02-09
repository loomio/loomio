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
    default_hocuspocus_url = Rails.env.production? ? "wss://hocuspocus.#{ENV['CANONICAL_HOST']}" : "ws://localhost:4444"

    light = {
      primary: ENV['THEME_LIGHT_PRIMARY'],
      info: ENV['THEME_LIGHT_INFO'],
      error: ENV['THEME_LIGHT_ERROR'],
      warning: ENV['THEME_LIGHT_WARNING'],
      success: ENV['THEME_LIGHT_SUCCESS'],
      anchor: ENV['THEME_LIGHT_ANCHOR'],
      background: ENV['THEME_LIGHT_BACKGROUND']
    }

    lightblue = {
      primary: ENV['THEME_LIGHTBLUE_PRIMARY'],
      info: ENV['THEME_LIGHTBLUE_INFO'],
      error: ENV['THEME_LIGHTBLUE_ERROR'],
      warning: ENV['THEME_LIGHTBLUE_WARNING'],
      success: ENV['THEME_LIGHTBLUE_SUCCESS'],
      anchor: ENV['THEME_LIGHTBLUE_ANCHOR'],
      background: ENV['THEME_LIGHTBLUE_BACKGROUND']
    }

    dark = {
      primary: ENV['THEME_DARK_PRIMARY'],
      info: ENV['THEME_DARK_INFO'],
      error: ENV['THEME_DARK_ERROR'],
      warning: ENV['THEME_DARK_WARNING'],
      success: ENV['THEME_DARK_SUCCESS'],
      anchor: ENV['THEME_DARK_ANCHOR'],
      background: ENV['THEME_DARK_BACKGROUND']
    }

    darkblue = {
      primary: ENV['THEME_DARKBLUE_PRIMARY'],
      info: ENV['THEME_DARKBLUE_INFO'],
      error: ENV['THEME_DARKBLUE_ERROR'],
      warning: ENV['THEME_DARKBLUE_WARNING'],
      success: ENV['THEME_DARKBLUE_SUCCESS'],
      anchor: ENV['THEME_DARKBLUE_ANCHOR'],
      background: ENV['THEME_DARKBLUE_BACKGROUND']
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
      icon_src: ENV.fetch('THEME_ICON_SRC', "/brand/icon_gold_150h.png"),
      app_logo_src: ENV.fetch('THEME_APP_LOGO_SRC', "/brand/logo_gold.svg"),
      saml_login_provider_name: ENV.fetch('SAML_LOGIN_PROVIDER_NAME', 'SAML'),
      oauth_login_provider_name: ENV.fetch('OAUTH_LOGIN_PROVIDER_NAME', 'OAUTH'),
      # used in emails
      email_header_logo_src: ENV.fetch('THEME_EMAIL_HEADER_LOGO_SRC', "/brand/logo_gold_96h.png"),
      email_footer_logo_src: ENV.fetch('THEME_EMAIL_FOOTER_LOGO_SRC', "/brand/logo_gold_48h.png"),
      primary_color: ENV.fetch('THEME_PRIMARY_COLOR', brand_colors[:sky]),
      accent_color: ENV.fetch('THEME_ACCENT_COLOR', brand_colors[:gold]),
      text_on_primary_color: ENV.fetch('THEME_TEXT_ON_PRIMARY_COLOR', '#ffffff'),
      text_on_accent_color: ENV.fetch('THEME_TEXT_ON_ACCENT_COLOR', '#ffffff'),
      default_invitation_message: ENV['THEME_DEFAULT_INVITATION_MESSAGE'],
      default_dark_theme: ENV.fetch('THEME_DEFAULT_DARK_THEME', 'dark'),
      default_light_theme: ENV.fetch('THEME_DEFAULT_LIGHT_THEME', 'light'),
      light: light,
      dark: dark,
      lightblue: lightblue,
      darkblue: darkblue
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
      sso_disable_edit_profile: !!ENV['LOOMIO_SSO_FORCE_USER_ATTRS'],
      sentry_sample_rate: ENV.fetch('SENTRY_SAMPLE_RATE', 0.1).to_f,
      hidden_poll_templates: %w[proposal question],
      transcription: TranscriptionService.available?,
      max_message_length: ENV.fetch('LMO_MAX_MESSAGE_LENGTH', 100000),
      sitemap: ENV.fetch('FEATURES_SITEMAP', false)
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
