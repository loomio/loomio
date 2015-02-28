class RecountEverythingAgain < ActiveRecord::Migration
  def change
    DiscussionService.recount_everything!
  end
end
