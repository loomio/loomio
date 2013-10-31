require 'spec_helper'

describe DiscussionReader do

  describe "unread?" do
    before do
      @reader = DiscussionReader.new
      @reader.last_read_at = 1.hour.ago
    end
    subject do
      @reader.unread?(time)
    end
    context "time after last_read_at" do
      let(:time) {Time.now}
      it {should be_true}
    end
    context "time before last_read_at" do
      let(:time) {2.hours.ago}
      it {should be_false}
    end
  end

  describe "#first_unread_page" do
    let(:user) { FactoryGirl.create :user }
    let(:other_user) { FactoryGirl.create :user }
    let(:discussion) { FactoryGirl.create :discussion }
    let(:reader) { discussion.as_read_by(user) }

    before do
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
