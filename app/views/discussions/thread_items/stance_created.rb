# frozen_string_literal: true

class Views::Discussions::ThreadItems::StanceCreated < Views::Base
  def initialize(item:, current_user:, kind: :created)
    @item = item
    @current_user = current_user
    @kind = kind
  end

  def view_template
    stance = @item.eventable
    poll = stance.poll
    voter = stance.participant
    div(class: "stance-created#{' mt-2' if @kind == :created}") do
      div(class: "thread-item #{@kind == :created ? 'pl-2' : 'px-3'} pb-1") do
        div(class: "#{@kind == :created ? 'v-layout' : 'layout'} lmo-action-dock-wrapper ml-5") do
          div(class: "thread-item__avatar mr-3 mt-0") do
            render Views::Email::Common::Avatar.new(user: voter, size: 24)
          end
          div(class: "#{@kind == :updated ? 'layout ' : ''}thread-item__body#{' column' if @kind == :updated}") do
            if @kind == :created && stance.revoked_at
              plain t("poll_common_votes_panel.vote_removed")
            else
              render Views::Discussions::StanceBody.new(stance: stance, voter: voter, poll: poll, current_user: @current_user)
            end
          end
        end
      end
    end
  end
end
