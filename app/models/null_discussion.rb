class NullDiscussion
  include Null::Object

  def initialize
    apply_null_methods!
  end

  def group
    self
  end

  alias :read_attribute_for_serialization :send

  def title
    "Null discussion"
  end

  def nil_methods
    %w(
      id
      key
      presence
      present?
      content_locale
      description
      description_format
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
      readers: :user
    }
  end
end
