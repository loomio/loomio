class Queries::VisibleAutocompletes < Delegator

  def initialize(query: , group: , pending: nil,  limit: , offset: 0,  current_user: )
    # want to match only first part of each word
    #
    # searching for 'rob'
    # 'robguthrie' should be true
    # 'emrob guthrie' should be false
    # 'james robinson' should be true
    #
    @relation = if pending
      Memberhship.pending
    else
      Membership.active
    end

    @relation =  @relation.joins(:user).joins(:group)
                          .where(group: group)
                          .where("users.id != ?", current_user.id)
                          .where("users.name ilike :qFirstWord OR
                                  users.name ilike :qOtherWord OR
                                  users.username ilike :qFirstWord",
                                  qFirstWord: "#{query}%",
                                  qOtherWord: "% #{query}%")
    if query.to_s.length > 0
      @relation = @relation.order('users.name')
    else
      @relation = @relation.order('created_at desc')
    end

    @relation = @relation.limit(limit).offset(offset)
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

end
