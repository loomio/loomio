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
      created_at
      author_id
    )
  end

  def true_methods
    []
  end

  def empty_methods
    [:member_ids, :voter_ids]
  end

  def none_methods
    {
      admins: :user,
      members: :user,
      memberships: :membership,
      voters_cast: :user,
      voters_uncast: :user,
      voters_cast_unmasked: :user,
      voters_uncast_unmasked: :user,
      voters_unmasked: :user,
      non_voters: :user,
      voters: :user
    }
  end
end
