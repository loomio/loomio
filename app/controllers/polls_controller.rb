class PollsController < ApplicationController
  include UsesMetadata

  def manage
    current_user_or_visitor.ability.authorize! :manage, resource
    show
  end
end
