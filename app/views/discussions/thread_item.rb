# frozen_string_literal: true

class Views::Discussions::ThreadItem < Views::Application::Component
  def initialize(item:, current_user:)
    @item = item
    @current_user = current_user
  end

  def view_template
    if @item.eventable.discarded?
      render Views::Discussions::ThreadItems::Removed.new(item: @item, current_user: @current_user)
    else
      case @item.kind
      when "new_comment"
        render Views::Discussions::ThreadItems::NewComment.new(item: @item, current_user: @current_user)
      when "poll_created"
        render Views::Discussions::ThreadItems::PollCreated.new(item: @item, current_user: @current_user)
      when "stance_created"
        render Views::Discussions::ThreadItems::StanceCreated.new(item: @item, current_user: @current_user, kind: :created)
      when "stance_updated"
        render Views::Discussions::ThreadItems::StanceCreated.new(item: @item, current_user: @current_user, kind: :updated)
      end
    end
  end
end
