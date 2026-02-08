class GroupsController < ApplicationController
  before_action :require_signed_in_user_for_explore, only: [:index]

  def index
    groups = Queries::ExploreGroups.new.search_for(params[:q]).order('groups.memberships_count DESC')
    total = groups.count
    limit = params.fetch(:limit, 50).to_i
    pages = total <= limit ? 1 : (total.to_f / limit).ceil
    page = params.fetch(:page, 1).to_i.clamp(1, pages)
    offset = page == 1 ? 0 : ((page - 1) * limit)
    render Views::Web::Groups::Index.new(
      groups: groups.limit(limit).offset(offset), pages: pages, page: page,
      metadata: metadata, export: !!params[:export], bot: browser.bot?
    )
  end

  def show
    resource = ModelLocator.new(resource_name, params).locate!
    @recipient = current_user
    if current_user.can? :show, resource
      assign_resource
      respond_to do |format|
        format.html do
          render Views::Web::Groups::Show.new(
            group: @group, recipient: @recipient,
            metadata: metadata, export: !!params[:export], bot: browser.bot?
          )
        end
        format.xml
      end
    else
      respond_with_error 403
    end
  end

  def export
    @exporter = GroupExporter.new(load_and_authorize(:group, :export))
    respond_to do |format|
      format.html { render Views::Web::Groups::Export.new(exporter: @exporter) }
    end
  end

  private

  def require_signed_in_user_for_explore
    require_current_user if AppConfig.app_features[:restrict_explore_to_signed_in_users]
  end
end
