class BlogStory < ActiveRecord::Base

  def thumb_url
    "#{image_url}&w=500&h=310&crop=1"
  end
end
