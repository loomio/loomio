class GroupExporter

  attr_reader :groups,      :group_fields,
              :memberships, :membership_fields,
              :invitations, :invitation_fields,
              :discussions, :discussion_fields,
              :comments,    :comment_fields,
              :polls,       :poll_fields,
              :stances,     :stance_fields,
              :field_names

  def initialize(group, group_ids)
    @group = group
    @groups = FormalGroup.where(id: group_ids)
    @group_fields = %w[id key name description created_at]

    @memberships = Membership.where(group_id: group_ids).chronologically
    @membership_fields = %w[group_id user_id user_name admin created_at]

    @invitations = Invitation.where(group_id: group_ids).chronologically
    @invitation_fields = %w[id group_id recipient_email inviter_name accepted_at]

    @discussions = Discussion.where(group_id: group_ids).chronologically
    @discussion_fields = %w[id group_id author_id author_name title description created_at]

    @comments = Comment.joins(:discussion => :group).where('discussions.group_id' => group_ids).chronologically
    @comment_fields = %w[id group_id discussion_id author_id discussion_title author_name body created_at]

    @polls = Poll.joins(:discussion => :group).where('discussions.group_id' => group.id_and_subgroup_ids).chronologically
    @poll_fields = %w[id key discussion_id group_id author_id title details closing_at closed_at created_at poll_type multiple_choice custom_fields]

    @stances = Stance.joins(:poll => {:discussion => :group}).where('discussions.group_id' => group_ids).chronologically
    @stance_fields = %w[id poll_id participant_id reason latest created_at updated_at]

    @field_names = {}
  end

  def to_csv(opts = {})
    CSV.generate(opts) do |csv|
      csv << ["Export for #{@group.full_name}"]
      csv << []

      csv_append(csv, @group_fields, @groups, "Groups")
      csv_append(csv, @membership_fields, @memberships, "Memberships")
      csv_append(csv, @discussion_fields, @discussions, "Discussions")
      csv_append(csv, @comment_fields, @comments, "Comments")
      csv_append(csv, @poll_fields, @polls, "Polls")
      csv_append(csv, @stance_fields, @stances, "Stances")
    end
  end

  private

  def csv_append(csv, fields, models, title)
    csv << ["#{title} (#{models.length})"]
    csv << fields.map(&:humanize)
    models.each { |model| csv << fields.map { |field| model.send(field) } }
    csv << []
  end
end
