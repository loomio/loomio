class NullPoll
  include Null::Object

  def initialize
    apply_null_methods!
  end

  def group
    self
  end

  alias :read_attribute_for_serialization :send

  def title
    "Null poll"
  end

  def nil_methods
    %w(
      id
      key
      presence
      present?
      content_locale
      details
      details_format
      group_id
      message_channel
      created_at
      author_id
    )
  end

  def true_methods
    []
  end

  def empty_methods
    [:member_ids]
  end

  def none_methods
    {
      admins: :user,
      members: :user,
      memberships: :membership,
      unmasked_decided_voters: :user,
      unmasked_undecided_voters: :user,
      unmasked_voters: :user,
      non_voters: :user
    }
  end
end
