class Queries::VisibleAutocompletes < Delegator

  def initialize(query: , group: , limit: , current_user: )
    # want to match only first part of each word
    #
    # searching for 'rob'
    # 'robguthrie' should be true
    # 'emrob guthrie' should be false
    # 'james robinson' should be true
    #
    @relation = Membership.active.joins(:user).joins(:group)
                          .where(group: group)
                          .where("users.id != ?", current_user.id)
                          .where("users.name ilike :qFirstWord OR
                                  users.name ilike :qOtherWord OR
                                  users.username ilike :qFirstWord",
                                  qFirstWord: "#{query}%",
                                  qOtherWord: "% #{query}%")
                          .limit(limit)
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

end
