module MoveDiscussionsHelper

  def destination_ids_for(discussion, user, visibility)
    method = case visibility
      when :private  then :private_discussions_only?
      when :public   then :public_discussions_only? 
    end

    @destination_groups.select(&method).map(&:id).join(' ')
  end

end
