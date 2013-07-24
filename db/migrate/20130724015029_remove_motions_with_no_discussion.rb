class RemoveMotionsWithNoDiscussion < ActiveRecord::Migration
  class Discussion < ActiveRecord::Base
    has_many :motions, :dependent => :destroy
    has_many :events, :as => :eventable, :dependent => :destroy
    has_many :comments,  :as => :commentable, :dependent => :destroy
  end
  class Motion < ActiveRecord::Base
    has_many :votes, :dependent => :destroy
    has_many :did_not_votes, :dependent => :destroy
    has_many :events, :as => :eventable, :dependent => :destroy
  end
  class Vote < ActiveRecord::Base
  end
  class DidNotVote < ActiveRecord::Base
  end
  class Event < ActiveRecord::Base
    has_many :notifications, :dependent => :destroy
  end
  class Notification < ActiveRecord::Base
  end

  def up
    Discussion.where(is_deleted: true).destroy_all
  end

  def down
  end
end
