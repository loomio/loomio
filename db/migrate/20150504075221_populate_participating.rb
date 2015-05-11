class PopulateParticipating < ActiveRecord::Migration
  class DiscussionService
    define_singleton_method :mark_as_participating!, ->{}
  end

  def up
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Discussion.count )
    DiscussionService.mark_as_participating! { progress_bar.increment }
  end

  def down
  end
end
