class PollsController < ApplicationController
  include UsesMetadata

  def share
    current_user.ability.authorize! :share, resource
    show
  end

  def embed
    @info = PollEmailInfo.new(
      recipient:   LoggedOutUser.new,
      poll:        load_and_authorize(:poll),
      actor:       LoggedOutUser.new,
      action_name: :embed
    )
    render layout: false
  end
end
