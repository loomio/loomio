module PublicGroupsHelper

  def first_page?
    params[:page] == nil || params[:page] == "1"
  end

end



