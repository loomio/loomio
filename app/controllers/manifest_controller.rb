class ManifestController < ApplicationController
  respond_to :json

  ICON_SIZES = %w(192 512).freeze

  def show
    render json: {
      name:             AppConfig.theme[:site_name],
      short_name:       AppConfig.theme[:site_name],
      display:          'standalone',
      orientation:      'portrait',
      start_url:        '/dashboard',
      background_color: AppConfig.theme[:brand_colors][:yellow425],
      theme_color:      AppConfig.theme[:primary_color],
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
