class ManifestController < ApplicationController
  ICON_DEFINITIONS = [
    ['192', :icon192_src, 'any'],
    ['512', :icon512_src, 'any'],
    ['192', :icon_maskable192_src, 'maskable'],
    ['512', :icon_maskable512_src, 'maskable']
  ].freeze

  IMAGE_TYPES = {
    '.jpeg' => 'image/jpeg',
    '.jpg' => 'image/jpeg',
    '.png' => 'image/png',
    '.svg' => 'image/svg+xml',
    '.webp' => 'image/webp'
  }.freeze

  def show
    render json: {
      id:               '/',
      scope:            '/',
      name:             AppConfig.theme[:site_name],
      short_name:       AppConfig.theme[:site_short_name],
      description:      AppConfig.theme[:site_description],
      display:          'standalone',
      start_url:        '/dashboard',
      background_color: AppConfig.theme[:brand_colors][:white],
      theme_color:      AppConfig.theme[:primary_color],
      icons:            ICON_DEFINITIONS.filter_map { |definition| icon_for(*definition) }
    }, content_type: 'application/manifest+json'
  end

  private

  def icon_for(size, source_key, purpose)
    source = AppConfig.theme[source_key]
    return if source.blank?

    {
      src: icon_url(source),
      sizes: "#{size}x#{size}",
      type: IMAGE_TYPES[File.extname(URI.parse(source).path).downcase],
      purpose: purpose
    }.compact
  end

  def icon_url(source)
    return source if URI.parse(source).absolute?

    URI.join(root_url, source).to_s
  end
end
