class GroupsController < ApplicationController
  before_action :require_signed_in_user_for_explore, only: [:index]

  def index
    return boot_app unless params[:export] || browser.bot?

    groups = Queries::ExploreGroups.new.search_for(params[:q]).order('groups.memberships_count DESC')
    total = groups.count
    limit = params.fetch(:limit, 50).to_i
    pages = total <= limit ? 1 : (total.to_f / limit).ceil
    page = params.fetch(:page, 1).to_i.clamp(1, pages)
    offset = page == 1 ? 0 : ((page - 1) * limit)
    render Views::Groups::Index.new(
      groups: groups.limit(limit).offset(offset), pages: pages, page: page,
      metadata: application_metadata, export: !!params[:export], bot: browser.bot?
    )
  end

  def show
    if params[:id].present?
      if group = Group.find_by(handle: params[:id])
        return render_group(group)
      end

      if redirect = GroupHandleRedirect.includes(:group).find_by(handle: params[:id])
        group = redirect.group
        unless current_user.can?(:show, group)
          return respond_with_error 403
        end

        return redirect_to group_handle_path(group.handle, request.query_parameters), status: :moved_permanently
      end
    end

    render_group(ModelLocator.new(resource_name, params).locate!)
  end

  def export
    group = load_and_authorize(:group, :export)
    GroupExportHtmlWorker.perform_later(group.id, current_user.id)
    redirect_to group_path(group), notice: I18n.t('group_export_started')
  end

  private

  def render_group(group)
    @group = group
    @recipient = current_user
    if current_user.can? :show, @group
      respond_to do |format|
        format.html do
          if params[:export] || browser.bot?
            page = [params[:page].to_i, 1].max
            render Views::Groups::Show.new(
              group: @group, recipient: @recipient, page: page,
              metadata: application_metadata, export: !!params[:export], bot: browser.bot?,
              canonical_url: canonical_url_for(@group, page > 1 ? { page: page } : {}), robots: robots_directive_for(@group)
            )
          else
            accept_pending_membership
            page = 'group_discussions' unless %w[polls members files emails membership_requests].include?(params[:slug])
            boot_app(page: page, resource: @group)
          end
        end
        format.xml
      end
    else
      respond_with_error 403
    end
  end

  def require_signed_in_user_for_explore
    require_current_user if AppConfig.app_features[:restrict_explore_to_signed_in_users]
  end
end
