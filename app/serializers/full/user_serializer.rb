class Full::UserSerializer < UserSerializer
  attributes :email, :email_when_proposal_closing_soon, :email_missed_yesterday,
             :email_when_mentioned, :email_on_participation, :selected_locale, :locale,
             :default_membership_volume, :experiences, :is_coordinator

  has_many :memberships,    serializer: MembershipSerializer, root: :memberships
  has_many :unread_threads, serializer: DiscussionSerializer, root: :discussions
  has_many :notifications,  serializer: NotificationSerializer, root: :notifications
  has_many :visitors,       serializer: VisitorSerializer, root: :visitors

  def memberships
    from_scope :memberships
  end

  def unread_threads
    from_scope :unread
  end

  def notifications
    from_scope :notifications
  end

  def visitors
    from_scope :visitors
  end

  def is_coordinator
    object.is_group_admin?
  end

  def include_gravatar_md5?
    true
  end

  private

  def from_scope(field)
    Array(Hash(scope)[field])
  end
end
