class UsernameGenerator
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def generate
    return safe_username unless conflict_exists?(safe_username)

    low = 1
    high = 1
    begin
      username = "#{safe_username}#{(low..high).to_a.sample}"
      high = high * 2
    end while conflict_exists?(username)
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

  def conflict_exists?(username)
    User.where(username: username).exists?
  end
end
