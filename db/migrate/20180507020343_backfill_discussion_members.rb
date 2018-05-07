require './legacy/backfill_discussion_members_job'

class BackfillDiscussionMembers < ActiveRecord::Migration[5.1]
  def change
    Delayed::Job.enqueue BackfillDiscussionMembersJob.new
  end
end
