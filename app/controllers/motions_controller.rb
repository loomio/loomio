class MotionsController < BaseController
  belongs_to :group
  def create
    build_resource
    @motion.author = current_user
    create!
  end

  def begin_of_association_chain
    @group
  end
end
