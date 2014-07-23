class CommentDecorator < ApplicationDecorator
  decorates :comment

  def title
    h.t(:comment_by, comment_author: author.name)
  end
end
