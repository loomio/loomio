# frozen_string_literal: true

class Views::Topics::TopicItem < Views::Application::Component
  def initialize(item:, current_user:)
    @item = item
    @current_user = current_user
  end

  def view_template
    if @item.eventable.discarded?
      render Views::Topics::TopicItems::Removed.new(item: @item, current_user: @current_user)
    else
      case @item.kind
      when "new_comment"
        render Views::Topics::TopicItems::NewComment.new(item: @item, current_user: @current_user)
      when "poll_created"
        render Views::Topics::TopicItems::PollCreated.new(item: @item, current_user: @current_user)
      when "stance_created"
        render Views::Topics::TopicItems::StanceCreated.new(item: @item, current_user: @current_user, kind: :created)
      when "stance_updated"
        render Views::Topics::TopicItems::StanceCreated.new(item: @item, current_user: @current_user, kind: :updated)
      end
    end
  end
end
