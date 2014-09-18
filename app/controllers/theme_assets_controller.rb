class ThemeAssetsController < ApplicationController
  # remember to cache this a little bit..
  # caches_action :index, :cache_path => Proc.new { |c| c.params }
  #
  skip_before_action :verify_authenticity_token

  def show
    @theme = Theme.find(params[:id])
    #fresh_when last_modified: @product.published_at.utc, etag: @product
    if stale?(etag: @theme, last_modified: @theme.updated_at, public: true)
      respond_to do |format|
        format.css { render text: @theme.style, content_type: 'text/css' }
        format.js { render text: @theme.javascript, content_type: 'text/javascript' }
      end
    end
  end
end
