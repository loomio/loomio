class HotlinksController < ApplicationController
  layout 'pages'

  def show
    @hotlink = Hotlink.find_by_link(params[:short_url])
    
    if @hotlink.present?
      @hotlink.update_attribute :use_count, @hotlink.use_count+1
      redirect_to @hotlink.linkable
    else
      render "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end

end
