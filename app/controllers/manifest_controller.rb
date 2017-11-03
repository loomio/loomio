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
      theme_color: AppConfig.theme[:accent_color],
      icons: [{
        src:   [root_url.chomp('/'), AppConfig.theme[:icon32_src]].join(''),
        sizes: '32x32',
        type:  'image/png'
        }, {
        src:   [root_url.chomp('/'), AppConfig.theme[:icon48_src]].join(''),
        sizes: '48x48',
        type:  'image/png'
        }, {
        src:   [root_url.chomp('/'), AppConfig.theme[:icon128_src]].join(''),
        sizes: '128x128',
        type:  'image/png'
        }, {
        src:   [root_url.chomp('/'), AppConfig.theme[:icon144_src]].join(''),
        sizes: '144x144',
        type:  'image/png'
        }, {
        src:   [root_url.chomp('/'), AppConfig.theme[:icon192_src]].join(''),
        sizes: '192x192',
        type:  'image/png'
        }, {
        src:   [root_url.chomp('/'), AppConfig.theme[:icon512_src]].join(''),
        sizes: '512x512',
        type:  'image/png'
      }]
    }
  end
end
