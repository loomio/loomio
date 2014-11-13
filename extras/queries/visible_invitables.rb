class Queries::VisibleInvitables < Delegator

  def initialize(query: nil, group: nil, user: nil, limit: nil)
    @user, @group, @query, @limit = user, group, query, limit

    @relation = (groups + contacts + visible_members)
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def contacts
    @user.contacts.where("name ilike '%#{@query}%' or email ilike '%#{@query}%'")
                  .limit(@limit)
  end

  def groups
    @user.groups.where("name ilike '%#{@query}%'")
                .where('groups.id != ?', @group.id)
                .limit(@limit)
  end

  def visible_members
    @user.relations.where("users.name ilike '%#{@query}%' or users.username ilike '%#{@query}%'")
                   .where('groups.id != ?', @group.id)
                   .uniq
                   .limit(@limit)
  end

end
