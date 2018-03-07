class Members::Group < Members::Base
  def priority
    2
  end

  def key
    "group-#{group.id}"
  end

  def title
    "#{group.full_name} (#{group.headcount})"
  end

  def subtitle
    I18n.t(:"notified.group_subtitle", members: group.memberships_count, invitations: group.pending_invitations_count)
  end

  def logo_url
    group.logo.url(:thumb)
  end

  def logo_type
    :uploaded
  end

  # NB: This is technically an N+1 query.
  # User and invitation do this in the `with_last_notified_at` scope, because
  # there could be many of them. Groups are less likely to be affected, so leaving for now.
  def last_notified_at
    group.announcees.where(announcement: model.announcements, announceable: group).maximum(:created_at)
  end

  private

  def group
    @group ||= model.group
  end
end
