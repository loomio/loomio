class GroupsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!, except: :show
  before_filter :boot_angular_ui, only: :show

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.group_private_or_not_found') }
  end

  def show
  end

  def export
    #@group
    @group_ids = [@group.id, @group.subgroup_ids].flatten
    @groups = Group.where(id: @group_ids)

    @group_fields = %w[id key name description created_at]

    @memberships = Membership.where(group_id: @group_ids).chronologically
    @membership_fields = %w[group_id user_id user_name admin created_at]

    @invitations = Invitation.where(invitable_id: @group_ids, invitable_type: 'Group').chronologically
    @invitation_fields = %w[id invitable_id recipient_email inviter_name accepted_at]

    @discussions = Discussion.where(group_id: @group_ids).chronologically
    @discussion_fields = %w[id group_id author_id author_name title description created_at]

    @comments = Comment.joins(:discussion => :group).where('discussions.group_id' => @group_ids).chronologically
    @comment_fields = %w[id group_id discussion_id author_id discussion_title author_name body created_at]

    @proposals = Motion.joins(:discussion => :group).where('discussions.group_id' => @group_ids).chronologically
    @proposal_fields = %w[id group_id discussion_id author_id discussion_title author_name proposal_title description created_at closed_at outcome yes_votes_count no_votes_count abstain_votes_count block_votes_count closing_at did_not_votes_count votes_count]

    @votes = Vote.joins(:motion => {:discussion => :group}).where('discussions.group_id' => @group_ids).chronologically
    @vote_fields = %w[id group_id discussion_id motion_id user_id discussion_title motion_name user_name position statement created_at]

    @field_names = {'motion_name' => 'proposal_title', 'invitable_id' => 'group_id', 'motion_id' => 'proposal_id'}

    if request[:format] == 'xls'
      render content_type: 'application/vnd.ms-excel', layout: false
    else
      render layout: false
    end
  end

  private

  def metadata
    @metadata ||= Metadata::GroupSerializer.new(load_group).as_json
  end

end
