# frozen_string_literal: true

class Admin::GroupsController < Admin::BaseController
  before_action :load_group, only: %i[show edit update move handle undiscard warn_then_destroy destroy_immediately export_group]

  def index
    groups, pagination = paginate(filtered_groups)
    render Views::Admin::Groups::Index.new(groups: groups, pagination: pagination, filters: filter_params)
  end

  def show
    render Views::Admin::Groups::Show.new(group: @group)
  end

  def edit
    render Views::Admin::Groups::Edit.new(group: @group)
  end

  def update
    @group.assign_attributes_and_files(group_params)
    privacy_change = GroupService::PrivacyChange.new(@group)
    if @group.save
      privacy_change.commit!
      redirect_to admin_group_path(@group), notice: "Group updated"
    else
      render Views::Admin::Groups::Edit.new(group: @group), status: :unprocessable_entity
    end
  end

  def delete_spam
    group_ids.each do |group_id|
      next unless Group.any_trial.exists?(group_id)

      group = Group.find(group_id)
      user = group.creator || group.admins.first
      DestroyUserWorker.perform_later(user.id) if user
    end
    redirect_to admin_groups_path, notice: "#{group_ids.size} spammy groups scheduled for deletion"
  end

  def import
    render Views::Admin::Groups::Import.new
  end

  def import_json
    ImportGroupWorker.perform_later(params.require(:url))
    redirect_to admin_groups_path, notice: "Import started. Check /admin/jobs for progress"
  end

  def add_admin
    membership = Membership.find(params.require(:membership_id))
    membership.update!(admin: true)
    redirect_to admin_group_path(membership.group), notice: "Admin added"
  end

  def remove_admin
    membership = Membership.find(params.require(:membership_id))
    membership.update!(admin: false)
    redirect_to admin_group_path(membership.group), notice: "Admin removed"
  end

  def move
    parent = Group.friendly.find(params.require(:parent_id))
    GroupService.move(group: @group, parent: parent, actor: current_user)
    redirect_to admin_group_path(@group), notice: "Group moved"
  end

  def handle
    old_handle = GroupService.update_handle(group: @group, handle: params.require(:handle), actor: current_user)
    notice = if old_handle.present? && old_handle != @group.handle
      "Handle changed from '#{old_handle}' to '#{@group.handle}'"
    else
      "Handle unchanged"
    end
    redirect_to admin_group_path(@group), notice: notice
  end

  def undiscard
    @group.undiscard!(actor: current_user)
    redirect_to admin_group_path(@group), notice: "Group restored"
  end

  def warn_then_destroy
    GroupService.warn_then_destroy(group: @group, actor: current_user)
    redirect_to admin_groups_path, notice: "Group administrators warned; deletion scheduled in 2 weeks"
  end

  def destroy_immediately
    GroupService.destroy_immediately!(@group.id, actor: current_user)
    redirect_to admin_groups_path, notice: "Group deletion scheduled immediately"
  end

  def export_group
    if @group.discarded?
      return redirect_to admin_group_path(@group), alert: "Restore the group before exporting it"
    end

    GroupExportWorker.perform_later(@group.all_groups.pluck(:id), @group.name, current_user.id)
    redirect_to admin_group_path(@group), notice: "Group export started"
  end

  def export_users
    render Views::Admin::Groups::ExportUsers.new
  end

  def export_users_report
    ids = params.fetch(:group_ids, "").split.filter_map { |id| Integer(id, exception: false) }
    users = User.joins(:memberships).where(memberships: { group_id: ids })
    users = users.where(memberships: { admin: true }) if params[:coordinators].present?
    render Views::Admin::Groups::ExportUsersReport.new(users: users.distinct)
  end

  private

  def load_group
    @group = Group.friendly.find(params[:id])
  end

  def filtered_groups
    relation = Group.order(created_at: :desc)
    filters = filter_params
    if filters[:search].present?
      search = "%#{ActiveRecord::Base.sanitize_sql_like(filters[:search])}%"
      relation = relation.where("groups.name ILIKE :search OR groups.handle ILIKE :search OR groups.description ILIKE :search", search: search)
    end
    relation = relation.where(parent_id: nil) if filters[:parents_only] == "1"
    relation = relation.not_demo if filters[:not_demo] == "1"
    relation = relation.where("memberships_count >= ?", filters[:memberships_min].to_i) if filters[:memberships_min].present?
    relation = relation.where(created_at: Date.parse(filters[:created_from])..) if filters[:created_from].present?
    relation = relation.where(created_at: ..Date.parse(filters[:created_to]).end_of_day) if filters[:created_to].present?
    relation
  rescue Date::Error
    relation
  end

  def filter_params
    params.permit(:search, :parents_only, :not_demo, :memberships_min, :created_from, :created_to, :page, :commit).except(:page, :commit)
  end

  def group_params
    params.require(:group).permit(
      :admin_tags, :parent_id, :handle, :subscription_id, :is_visible_to_public,
      :is_visible_to_parent_members, :parent_members_can_see_discussions,
      :membership_granted_upon
    )
  end

  def group_ids
    Array(params[:group_ids]).filter_map { |id| Integer(id, exception: false) }
  end
end
