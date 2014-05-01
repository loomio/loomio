class Admin::StatsController < Admin::BaseController
  def events
    scope = Event.includes(:eventable, :discussion)

    if params[:created_at_gt]
      scope = scope.where('created_at > ?', params[:created_at_gt])
    end

    if params[:created_at_lt]
      scope = scope.where('created_at < ?', params[:created_at_lt])
    end

    @events = scope

    if params[:group_id].present?
      @group = Group.find(params[:group_id])
      @events = @events.includes(:eventable).select{|e| e.eventable.present? && e.eventable.group_id == @group.id }
    end
  end
end
