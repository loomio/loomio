class Events::MembershipResent < Event
  include Events::Notify::ByEmail

  def self.publish!(membership, actor)
    super membership.group,
          user: actor,
          custom_fields: { membership_id: membership.id }
  end

  def email_subject_key
    "#{eventable_key}_mailer.resend"
  end

  private

  def email_method
    :"#{eventable_key}_announced"
  end

  def email_recipients
    User.where(id: membership.user_id)
  end

  def eventable_key
    return :group if eventable.is_a?(Group)
    eventable.class.to_s.downcase
  end

  def membership
    Membership.find(custom_fields['membership_id'])
  end
end
