class ManifestController < ApplicationController
  respond_to :json

  def service_worker
  end

  ICON_SIZES = %w(32 48 128 144 192 512).freeze
  def show
    render json: {
      name:             AppConfig.theme[:site_name],
      short_name:       AppConfig.theme[:site_name],
      display:          'standalone',
      orientation:      'portrait',
      start_url:        '/dashboard',
      background_color: AppConfig.theme[:primary_color],
      theme_color:      AppConfig.theme[:text_on_primary_color],
      icons:            ICON_SIZES.map { |size| icon_for(size) }
    }
  end

  private

  def icon_for(size)
    {
      src: [root_url.chomp('/'), AppConfig.theme[:"icon#{size}_src"]].join(''),
      sizes: "#{size}x#{size}",
      type: "image/png"
    }
  end
end
