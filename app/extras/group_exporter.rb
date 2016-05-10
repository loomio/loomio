class GroupExporter

  attr_reader :groups,      :group_fields,
              :memberships, :membership_fields,
              :invitations, :invitation_fields,
              :discussions, :discussion_fields,
              :comments,    :comment_fields,
              :proposals,   :proposal_fields,
              :votes,       :vote_fields,
              :field_names

  def initialize(group)
    @group = group
    @groups = Group.where(id: group.id_and_subgroup_ids)
    @group_fields = %w[id key name description created_at]

    @memberships = Membership.where(group_id: group.id_and_subgroup_ids).chronologically
    @membership_fields = %w[group_id user_id user_name admin created_at]

    @invitations = Invitation.where(invitable_id: group.id_and_subgroup_ids, invitable_type: 'Group').chronologically
    @invitation_fields = %w[id invitable_id recipient_email inviter_name accepted_at]

    @discussions = Discussion.where(group_id: group.id_and_subgroup_ids).chronologically
    @discussion_fields = %w[id group_id author_id author_name title description created_at]

    @comments = Comment.joins(:discussion => :group).where('discussions.group_id' => group.id_and_subgroup_ids).chronologically
    @comment_fields = %w[id group_id discussion_id author_id discussion_title author_name body created_at]

    @proposals = Motion.joins(:discussion => :group).where('discussions.group_id' => group.id_and_subgroup_ids).chronologically
    @proposal_fields = %w[id group_id discussion_id author_id discussion_title author_name proposal_title description created_at closed_at outcome yes_votes_count no_votes_count abstain_votes_count block_votes_count closing_at voters_count members_count votes_count]

    @votes = Vote.joins(:motion => {:discussion => :group}).where('discussions.group_id' => group.id_and_subgroup_ids).chronologically
    @vote_fields = %w[id group_id discussion_id motion_id user_id discussion_title motion_name user_name position statement created_at]

    @field_names = {motion_name: :proposal_title, invitable_id: :group_id, motion_id: :proposal_id}
  end

  def to_csv(opts = {})
    CSV.generate(opts) do |csv|
      csv << ["Export for #{@group.full_name}"]
      csv << []
      
      csv_append(csv, @group_fields, @groups, "Groups")
      csv_append(csv, @membership_fields, @memberships, "Memberships")
      csv_append(csv, @discussion_fields, @discussions, "Discussions")
      csv_append(csv, @comment_fields, @comments, "Comments")
      csv_append(csv, @proposal_fields, @proposals, "Proposals")
      csv_append(csv, @vote_fields, @votes, "Votes")
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
