class CommentsController < ApplicationController
  def redirect
    comment = Comment.find(params[:id])
    redirect_to polymorphic_path(comment)
  end
end
