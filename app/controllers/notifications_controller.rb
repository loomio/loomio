class NotificationsController < BaseController
  def groups_tree_dropdown
    render layout: false
  end

  def dropdown_items
    @unviewed_notifications = current_user.unviewed_notifications.order('created_at DESC')
    @notifications = recent_notifications.order('created_at DESC')
    preload_associations
    render layout: false
  end

  def index
    @notifications = []
    @notifications = current_user.notifications.order('created_at DESC')
                     .includes(:event => [:eventable, :user])
                     .page(params[:page]).per(15)
    preload_associations
  end

  def mark_as_viewed
    current_user.mark_notifications_as_viewed! params[:latest_viewed]
    head :ok
  end

  private

  # Returns most recent notifications
  #   lower_limit - (minimum # of notifications returned)
  #   upper_limit - (maximum # of notifications returned)
  def recent_notifications(lower_limit=10, upper_limit=25)
    if current_user.unviewed_notifications.count < lower_limit
      current_user.notifications.limit(lower_limit)
    else
      current_user.unviewed_notifications.limit(upper_limit)
    end
  end

  def preload_associations
    motions = @notifications.select { |n| n.eventable.kind_of? Motion }.map(&:eventable)
    ActiveRecord::Associations::Preloader.new(motions, [{:discussion => :group}, :author]).run

    discussions = @notifications.select { |n| n.eventable.kind_of? Discussion }.map(&:eventable)
    ActiveRecord::Associations::Preloader.new(discussions, [:group, :author]).run

    comments = @notifications.select { |n| n.eventable.kind_of? Comment }.map(&:eventable)
    ActiveRecord::Associations::Preloader.new(comments, [{:discussion => :group}, :user]).run
  end
end
