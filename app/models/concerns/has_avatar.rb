module HasAvatar
  include AvatarInitials
  include Routing
  extend ActiveSupport::Concern

  included do
    include Gravtastic
    gravtastic rating: :pg, default: :none
    before_create :set_default_avatar_kind
  end

  def set_default_avatar_kind
    if uploaded_avatar.attached?
      self.avatar_kind = :uploaded
    else
      self.avatar_kind = :initials
    end
  end

  def avatar_kind
    return 'mdi-duck' if deactivated_at?
    return 'mdi-email-outline' if !name
    read_attribute(:avatar_kind)
  end

  def thumb_url
    avatar_url(128)
  end

  def avatar_url(size = 512)
    if avatar_kind == 'uploaded' && (!uploaded_avatar.attached? or uploaded_avatar.attachment.nil?)
      update_columns(avatar_kind: set_default_avatar_kind)
    end

    case avatar_kind
    when 'gravatar'
      gravatar_url(size: size, secure: true, default: 'retro')
    when 'uploaded'
      uploaded_avatar_url(size)
    else
      nil
    end
  rescue ActiveStorage::UnrepresentableError
    update_columns(avatar_kind: :initials)
    nil
  end

  def avatar_initials_url(size = 256)
    colors = AppConfig.theme[:brand_colors].slice(:yellow425, :blue400, :blue50, :grey100).values
    color = colors[id % colors.length].gsub('#','')
    params = {
      name: String(avatar_initials).split('').join('+'),
      background: colors[id % colors.length].gsub('#',''),
      color: '000000',
      rounded: true,
      format: :png,
      size: size
    }
    "https://ui-avatars.com/api/?#{params.to_a.map{|p| p.join('=')}.join('&')}"
  end

  def uploaded_avatar_url(size = 512)
    size = size.to_i
    return unless uploaded_avatar.attached?
    Rails.application.routes.url_helpers.rails_representation_path(
        uploaded_avatar.representation(resize_to_limit: [size,size], saver: {quality: 80, strip: true}),
        only_path: true
    )
  end

end
