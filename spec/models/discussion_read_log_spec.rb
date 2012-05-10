require 'spec_helper'

describe DiscussionReadLog do
  context "a new discussion_read_log" do
    subject do
      @log = discussion_read_log.new
      @log.valid?
      @log

      it "must have a discussion_activity_when_last_read, user and a motion" do
        @log.should have(1).errors_on(:discussion_activity_when_last_read)
        @log.should have(1).errors_on(:user_id)
        @log.should have(1).errors_on(:motion_id)
      end
    end
  end
end
