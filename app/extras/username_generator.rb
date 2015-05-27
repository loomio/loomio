UsernameGenerator = Struct.new(:user) do

  def generate
    begin
      i ||= 0
      username = "#{safe_username}#{i if i > 0}"
      i += 1
    end while conflicts.include? username
    username
  end

  private

  def base_username
    if user.name.present?
      user.name
    elsif user.email.present?
      user.email.split('@').first
    else
      'unknownuser'
    end
  end

  def safe_username
    ActiveSupport::Inflector.transliterate(base_username)
                            .downcase
                            .gsub(/[^a-z0-9]+/, '')[0,18]
  end

  def conflicts
    UsernameConflictsQuery.conflicts_for(safe_username).pluck(:username)
  end

end
