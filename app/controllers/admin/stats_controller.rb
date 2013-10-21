class Admin::StatsController < Admin::BaseController
  def events
    scope = Event.unscoped

    if params[:created_at_gt]
      scope = scope.where('created_at > ?', params[:created_at_gt])
    end

    if params[:created_at_lt]
      scope = scope.where('created_at < ?', params[:created_at_lt])
    end

    @events = scope

    if params[:group_id]
      @group = Group.find(params[:group_id])
      @events = @events.select{|e| e.eventable.present? && e.eventable.group == @group }
    end
  end
end
