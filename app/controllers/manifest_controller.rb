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
      theme_color: '#AED9EB',
      icons: [{
        src:   '/img/loomiologo32.png',
        sizes: '32x32',
        type:  'image/png'
        }, {
        src:   '/img/loomiologo48.png',
        sizes: '48x48',
        type:  'image/png'
        }, {
        src:   '/img/loomiologo128.png',
        sizes: '128x128',
        type:  'image/png'
        }, {
        src:   '/img/loomiologo144.png',
        sizes: '144x144',
        type:  'image/png'
        }, {
        src:   '/img/loomiologo192.png',
        sizes: '192x192',
        type:  'image/png'
        }, {
        src:   '/img/loomiologo512.png',
        sizes: '512x512',
        type:  'image/png'
      }]
    }
  end
end
