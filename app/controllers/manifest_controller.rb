class ManifestController < ApplicationController
  respond_to :json

  def show
    pwa_base_url = Rails.env.development? ? "http://localhost:8080" : "https://#{AppConfig.theme[:canonical_host]}"

    render json: {
      name:             AppConfig.theme[:site_name],
      short_name:       AppConfig.theme[:site_name],
      description:      AppConfig.theme[:site_description],
      display:          'standalone',
      orientation:      'portrait',
      start_url:        ENV.fetch('FEATURES_DEFAULT_PATH', dashboard_path),
      scope:            pwa_base_url,
      id:               pwa_base_url,
      background_color: AppConfig.theme[:primary_color],
      theme_color:      AppConfig.theme[:text_on_primary_color],
      icons:            [{ src: AppConfig.theme[:icon_src], sizes: "150x150"}],
      shortcuts: [
        { name: 'Dashboard', url: '/dashboard' },
        { name: 'Tasks', url: '/tasks' }
      ],
      #these 'screenshots' are used to force a more descriptive install prompt on chrome
      screenshots: [
        {
        src: root_url.chomp('/') + '/brand/banner_gold_400h.png',
        sizes: '858x400',
        form_factor: 'wide'
        },
        {
          src: root_url.chomp('/') + '/brand/banner_gold_400h.png',
          sizes: '858x400',
          form_factor: 'narrow'
        }
      ]
    }
  end
end
