class ThemeCssController < ApplicationController
  # remember to cache this a little bit..
  # caches_action :index, :cache_path => Proc.new { |c| c.params }
  def show
    @theme = Theme.find(params[:id])
    #fresh_when last_modified: @product.published_at.utc, etag: @product
    render text: @theme.style, content_type: 'text/css'
  end
end
