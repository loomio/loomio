require 'spec_helper'

describe Admin::StatsController do
  before do
    @user = FactoryGirl.create :admin_user
    sign_in @user
  end

  describe "GET 'events'" do
    it "honors created_at range" do
      discussion = FactoryGirl.create(:discussion)
      y2k_event = Event.create(created_at: Date.parse('2000-01-02'),
                               eventable: discussion,
                               kind: 'new_discussion')
      
      y2k1_event = Event.create(created_at: Date.parse('2001-01-02'),
                               eventable: discussion,
                               kind: 'new_discussion')

      get :events, format: 'json', created_at_gt: '2000-01-01', created_at_lt: '2001-01-01'
      assigns(:events).should include y2k_event
      assigns(:events).should_not include y2k1_event
    end

    it 'filters by group_id' do
      @nice_group = FactoryGirl.create :group
      @bad_group = FactoryGirl.create :group

      nice_discussion = FactoryGirl.create(:discussion, group: @nice_group)
      bad_discussion = FactoryGirl.create(:discussion, group: @bad_group)

      get :events, format: 'json', group_id: @nice_group.id

      assigns(:events).should include nice_discussion.events.first
      assigns(:events).should_not include bad_discussion.events.first
    end

  end
end
