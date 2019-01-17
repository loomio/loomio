module HasAvatar
  include AvatarInitials
  include Routing
  extend ActiveSupport::Concern

  AVATAR_SIZES = {
    small:  30,
    medium: 50,
    large:  170,
  }.with_indifferent_access.freeze

  included do
    include Gravtastic
    gravtastic rating: :pg, default: :none
    before_create :set_default_avatar_kind
  end

  def set_default_avatar_kind
    self.avatar_kind = if has_gravatar?
      :gravatar
    else
      :initials
    end
  end

  def avatar_kind
    return 'mdi-duck' if deactivated_at?
    return 'mdi-email-outline' if !name
    super
  end

  def uploaded_avatar(size)
    # NOOP: override for users who can upload avatars
  end

  def avatar_url(size = :medium)
    case avatar_kind.to_sym
    when :gravatar then gravatar_url(size: AVATAR_SIZES[size])
    when :uploaded then uploaded_avatar.url(size)
    end
  end

  def absolute_avatar_url(size = :medium)
    url = avatar_url(size)
    if url =~ /https:\/\//
      url
    elsif url
      [root_url(default_url_options).chomp('/'), url].join
    elsif self == User.helper_bot
      self.avatar_url
    else
      User.helper_bot.absolute_avatar_url
    end
  end

  def has_gravatar?(options = {})
    return false if Rails.env.test?
    hash = Digest::MD5.hexdigest(email.to_s.downcase)
    options = { :rating => 'x', :timeout => 2 }.merge(options)
    http = Net::HTTP.new('www.gravatar.com', 80)
    http.read_timeout = options[:timeout]
    response = http.request_head("/avatar/#{hash}?rating=#{options[:rating]}&default=http://gravatar.com/avatar")
    response.code != '302'
  rescue StandardError, Timeout::Error
    false  # Don't show "gravatar" if the service is down or slow
  end

end
