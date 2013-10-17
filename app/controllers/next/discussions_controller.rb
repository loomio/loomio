class Next::DiscussionsController < DiscussionsController
  layout 'next'

  def new_proposal
    discussion = Discussion.find(params[:id])
    @motion = Motion.new
    @motion.discussion = discussion
    @group = GroupDecorator.new(discussion.group)
    render 'next/motions/new'
  end
end