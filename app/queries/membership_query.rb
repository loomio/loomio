class MembershipQuery
  def self.start
    Membership.includes(:group, :user, :inviter).joins(:group).joins(:user)
  end

  def self.visible_to(user: , chain: start)
    chain.where("memberships.group_id IN (#{ids_or_null(user.group_ids)}) OR
                 groups.parent_id IN (#{ids_or_null(user.adminable_group_ids)})")
  end

  def self.search(chain: start, params:)
    if group = Group.find_by(id: params[:group_id])
      group_ids = case params[:subgroups]
        when 'mine', 'all'
          group.id_and_subgroup_ids
        else
          [group.id]
        end
      chain = chain.where(group_id: group_ids)
    end

    if params[:user_ids]
      chain = chain.where('memberships.user_id': params[:user_ids])
    end

    case params[:filter]
    when 'admin'
      chain = chain.admin
    when 'pending'
      chain = chain.pending
    when 'accepted'
      chain = chain.accepted
    end

    query = params[:q].to_s
    if query.length > 0
      chain = chain.where("users.name ilike :first OR users.name ilike :last OR
                           users.email ilike :first OR
                           users.username ilike :first",
                           first: "#{query}%", last: "% #{query}%")
    end

    chain
  end

  def self.ids_or_null(ids)
    if ids.length == 0
      'null'
    else
      ids.join(',')
    end
  end
end
