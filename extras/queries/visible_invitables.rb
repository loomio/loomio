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
    @user.contacts.where("name ilike #{search_term} or email ilike #{search_term}")
                  .limit(@limit)
  end

  def groups
    @user.groups.where("name ilike #{search_term}")
                .where('groups.id != ?', @group.id)
                .limit(@limit)
  end

  def visible_members
    Queries::VisibleMembers.new(user: @user, group: @group, query: @query, limit: @limit)
  end

  private

  def search_term
    @like_term ||= "'%#{@query}%'"
  end

end
