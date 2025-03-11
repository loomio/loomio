class ManifestController < ApplicationController
  respond_to :json

  ICON_SIZES = %w(128 150 256 300).freeze

  def show
    render json: {
      name:             AppConfig.theme[:site_name],
      short_name:       AppConfig.theme[:site_name],
      description:      AppConfig.theme[:site_description],
      display:          'standalone',
      orientation:      'portrait',
      start_url:        ENV.fetch('FEATURES_DEFAULT_PATH', dashboard_path),
      scope:            Rails.env.development? ? "http://localhost:8080" : "https://#{AppConfig.theme[:canonical_host]}",
      id:               Rails.env.development? ? "http://localhost:8080" : "https://#{AppConfig.theme[:canonical_host]}",
      background_color: AppConfig.theme[:primary_color],
      theme_color:      AppConfig.theme[:text_on_primary_color],
      icons:            ICON_SIZES.map { |size| icon_for(size) },
      shortcuts: [
        { name: 'Dashboard', url: '/dashboard' },
        { name: 'Tasks', url: '/tasks' }
      ],
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

  private

  def icon_for(size)
    {
      src: root_url.chomp('/') + '/brand/' + "icon_gold_#{size}h.png",
      sizes: "#{size}x#{size}",
      type: 'image/png'
    }
  end
end
