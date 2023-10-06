module Null::User
  # include HasAvatar
  include Null::Object
  def can?(*args)
    ability.can?(*args)
  end

  def ability
    @ability ||= Ability::Base.new(self)
  end

  def nil_methods
    [:id, :key, :username, :short_bio, :city, :region, :country, :selected_locale, :deactivated_at,
     :default_membership_volume, :unsubscribe_token, :location, :email_catch_up_day,
     :encrypted_password, :update_attribute, :last_seen_at, :legal_accepted_at]
  end

  def false_methods
    [:is_logged_in?, :is_member_of?, :is_admin_of?, :is_admin?, :is_admin, 
     :email_when_proposal_closing_soon, :has_password, :bot,
     :email_when_mentioned, :email_on_participation, :email_verified, :email_verified?, :email_newsletter, :marked_for_destruction?]
  end

  def empty_methods
    [:group_ids, :adminable_group_ids, :group_ids, :attachments, :guest_discussion_ids]
  end

  def hash_methods
    [:experiences]
  end

  def none_methods
    {
      notifications: :notification,
      login_tokens: :login_token,
      memberships: :membership,
      admin_memberships: :membership,
      participated_polls: :poll,
      group_polls: :poll,
      polls: :poll,
      stances: :stance,
      groups: :group
    }
  end

  def avatar_initials_url(size = 256)
    params = {
      name: "AU".split('').join('+'),
      background: AppConfig.theme[:brand_colors][:gold].gsub('#',''),
      color: '000000',
      rounded: true,
      format: :png,
      size: size
    }
    "https://ui-avatars.com/api/?#{params.to_a.map{|p| p.join('=')}.join('&')}"
  end

  def default_format
    "html"
  end
  
  def short_bio_format
    "html"
  end

  def identities
    Identities::Base.none
  end

  def is_admin?
    false
  end
end
