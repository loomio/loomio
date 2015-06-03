require 'rails_helper'
describe UserService do
  describe 'delete_spam' do
    let(:spam_user) { FactoryGirl.create :user }
    let(:spam_group) { FactoryGirl.build :group }
    let(:innocent_group) { FactoryGirl.create :group }

    before do
      #the create the spam group
      GroupService.create(group: spam_group, actor: user)

      #add a spammy discussion to the spam group
      DiscussionService.create(discussion: spam_discussion,


      # they join an innocent group such as loomio commune
      innocent_group.add_member! spam_user

      # spam the loomio commune group with a discussion
      # spam the loomio communie discussion with comments
    end

    it 'destroys the groups created by the user' do
      UserService.delete_spam(user)
      spam_group.persisted?.should be false
      innocent_group.persisted?.should be true
    end

    it 'destroys the user' do
      UserService.delete_spam(user)
      spam_user.persisted?.should be false
    end

    it 'destroys the discussions in the spammy groups' do

    end

    it 'does not destroy innocent group victims' do

    end
    
    it 'destroys comments in innocent groups' do

    end
  end
end
