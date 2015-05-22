class UsernameConflictsQuery
  def self.conflicts_for(username)
    User.where("username = '#{username}' OR username SIMILAR TO '#{username}\\d'", username: username)
  end
end
