class ManifestController < ApplicationController
  respond_to :json

  def show
    render json: {
      name: AppConfig.theme[:site_name],
      short_name: AppConfig.theme[:site_name],
      display: 'standalone',
      orientation: 'portrait',
      start_url: '/dashboard',
      background_color: '#ffffff',
      theme_color: '#ffffff',
      icons: [{
        src:   [root_url.chomp('/'), AppConfig.theme[:icon_src]].join(''),
        sizes: '144x144',
        type:  'image/png'
      }]
    }
  end
end
