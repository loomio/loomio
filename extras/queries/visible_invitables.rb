class Queries::VisibleInvitables < Delegator

  def initialize(query: nil, group: nil, user: nil, limit: nil)
    @user, @group, @query = user, group, query

    @relation = (my_contacts + my_groups + my_relations).take(limit)
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def my_contacts
    @user.contacts.where("name ilike '%#{@query}%' or email ilike '%#{@query}%'")
  end

  def my_groups
    @user.groups.where("name ilike '%#{@query}%'").where('groups.id != ?', @group.id)
  end

  def my_relations
    [] #Queries::VisibleRelations.new(current_user: @user, group: @group)
  end

end
