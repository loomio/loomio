module PublicGroupsHelper

  def set_names_order_link
    if params[:order_direction] == "ASC" || params[:order_direction] == nil
      public_groups_path(:order_column => 'name',:order_direction => 'DESC')
    else
      public_groups_path(:order_column => 'name',:order_direction => 'ASC')
    end
  end
        
  def set_memberships_count_order_link
    if params[:order_direction] == "ASC" || params[:order_direction] == nil
      public_groups_path(:order_column => 'memberships_count',:order_direction => 'DESC')
    else
      public_groups_path(:order_column => 'memberships_count',:order_direction => 'ASC')
    end
  end
end
