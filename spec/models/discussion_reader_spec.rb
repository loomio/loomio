require 'rails_helper'

describe DiscussionReader do

  let(:user) { FactoryGirl.create :user }
  let(:other_user) { FactoryGirl.create :user }
  let(:discussion) { FactoryGirl.create :discussion }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }

  describe "#follow!" do
    it "sets following to true" do
      reader.following.should be nil
      reader.follow!
      reader.following.should be true
    end
  end

  describe "#first_unread_page" do
    before do
      Discussion.send(:remove_const, 'PER_PAGE')
      Discussion::PER_PAGE = 2
      discussion.group.add_member! user
      discussion.group.add_member! other_user
    end

    subject do
      reader.first_unread_page
    end

    context '0 items' do
      it {should == 1}
    end

    context '0 read, 1 unread' do
      before do
        discussion.add_comment(other_user, 'hi')
      end
      it {should == 1}
    end

    context '1 read, 1 unread' do
      before do
        discussion.add_comment(other_user, 'hi')
        reader.viewed!
        discussion.add_comment(other_user, 'hi')
      end
      it {should == 1}
    end

    context '2 read, 1 unread' do
      before do
        discussion.add_comment(other_user, 'hi')
        discussion.add_comment(other_user, 'hi')
        reader.viewed!
        discussion.add_comment(other_user, 'hi')
        discussion.reload
      end
      it {should == 2}
    end
  end
end
