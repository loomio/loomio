class PollsController < ApplicationController
  include UsesMetadata

  def share
    current_user.ability.authorize! :share, resource
    show
  end
end
