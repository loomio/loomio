UsernameGenerator = Struct.new(:user) do

  def generate
    begin
      i ||= 0
      username = "#{base_username}#{i if i > 0}"
      i += 1
    end while conflicts.include? username
    username
  end

  private

  def base_username
    (user.name || user.email).split('@').first      # all characters before '@'
                             .parameterize          # convert ascii chars
                             .downcase              # all lower case
                             .gsub(/[^a-z0-9]/, '') # alphanumeric
                             .slice(0,18)           # first 18 characters
  end

  def conflicts
    UsernameConflictsQuery.conflicts_for(base_username).pluck(:username)
  end

end