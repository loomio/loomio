class PollsController < ApplicationController
  include UsesMetadata

  def share
    current_user_or_visitor.ability.authorize! :share, resource
    show
  end
end
