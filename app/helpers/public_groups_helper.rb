module PublicGroupsHelper

  def set_names_order_link
    if params[:order_direction] == "ASC"
      public_groups_path(:order_direction => "DESC")
    else
      public_groups_path(:order_direction => 'ASC')
    end
  end

  def set_alphabetise_icon
    if params[:order_direction] == nil || params[:order_direction] == "DESC"
      content_tag(:i, '', class: 'sort-by-alphabet-icon')
    else
      content_tag(:i, '', class: 'sort-by-alphabet-icon-desc')
    end
  end

  def first_page?
    params[:page] == nil || params[:page] == "1"
  end

end



