require 'spec_helper'

describe Event do
  it { should belong_to(:eventable) }
  it { should belong_to(:user) }
  it { should have_many(:notifications).dependent(:destroy) }
  it { should validate_presence_of(:eventable) }
  it { should allow_value("new_discussion").for(:kind) }
  it { should allow_value("new_comment").for(:kind) }
  it { should allow_value("new_vote").for(:kind) }
  it { should allow_value("motion_blocked").for(:kind) }
  it { should allow_value("membership_requested").for(:kind) }
  it { should allow_value("user_added_to_group").for(:kind) }
  it { should allow_value("comment_liked").for(:kind) }
  it { should allow_value("motion_outcome").for(:kind) }
  it { should_not allow_value("blah").for(:kind) }

  let(:discussion) { create(:discussion) }
  let(:group) { discussion.group }

  describe "new_discussion!" do
    subject { Event.new_discussion!(discussion) }

    its(:kind) { should eq("new_discussion") }
    its(:eventable) { should eq(discussion) }

    context "sending notifications" do
      before do
        @user = stub_model(User)
        @actor = stub_model(User, :send_notification? => true)
        @group = stub_model(Group)
        @discussion = stub_model(Discussion, :group => @group, 
          :group_users => [@user, @actor], :author => @actor)
        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end
      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true) }
        it "sends notification to user" do
          @notifications.should_receive(:create!).with(:user => @user)
          Event.new_discussion!(@discussion)
        end
        it "does not send notification to user if user is event actor" do
          @discussion.stub(:author => @user)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.new_discussion!(@discussion)
        end
      end
      context "user has muted this type of event" do
        it "does not send notification to user" do
          @user.stub(:send_notification? => false)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.new_discussion!(@discussion)
        end
      end
    end
  end

  describe "new_comment!" do
    context "sending notifications" do
      before do
        @user = stub_model(User)
        @actor = stub_model(User)
        @group = stub_model(Group)
        @discussion = stub_model(Discussion, :group => @group, 
          :group_users => [@user, @actor])
        @comment = stub_model(Comment, :discussion => @discussion, 
          :user => @actor)
        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end
      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true) }
          context "and is discussion participant" do
            before { @discussion.stub(:is_participant? => true) }
              it "sends notification to user who is a participant" do
                @notifications.should_receive(:create!).with(:user => @user)
                Event.new_comment!(@comment)
              end
              it "does not send notification to user if user is event actor" do
                @comment.user.stub(:user => @user)
                @notifications.should_not_receive(:create!).with(:user => @user)
              end
          end
        it "sends notification to user who is not a participant" do
          @discussion.stub(:is_participant? => false)
          @notifications.should_receive(:create!).with(:user => @user)
          Event.new_comment!(@comment)
        end

      end
      context "user has muted this type of event" do
        it "does not send notification to user" do
          @user.stub(:send_notification? => false)
          @discussion.stub(:is_participant? => true)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.new_comment!(@comment)
        end
      end
    end
  end

  describe "new_motion!" do
    let(:motion) { create(:motion) }
    subject { Event.new_motion!(motion) }

    its(:kind) { should eq("new_motion") }
    its(:eventable) { should eq(motion) }

    context "sending notifications" do
      before do
        @group = stub_model(Group)
        @user = stub_model(User)
        @motion = stub_model(Motion, :group => @group, 
          :group_users => [@user])
        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end

      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true) }

        it "sends notification to user" do
          @notifications.should_receive(:create!).with(:user => @user)
          Event.new_motion!(@motion)
        end

        it "does not send notification to user if user is author" do
          @motion.stub(:author => @user)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.new_motion!(@motion)
        end
      end

      context "user has muted this type of event" do
        it "does not send notification to user" do
          @user.stub(:send_notification? => false)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.new_motion!(@motion)
        end
      end
    end
  end

  describe "motion_outcome!" do
    context "sending notifications" do
      before do
        @group = stub_model(Group)
        @user = stub_model(User)
        @actor = stub_model(User, :send_notification? => true)
        @motion = stub_model(Motion, :group => @group, 
          :group_users => [@user, @actor], :outcome_stater => @actor)
        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end
      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true) }
        it "sends notification to user" do
          @notifications.should_receive(:create!).with(:user => @user)
          Event.motion_outcome!(@motion, @actor)
        end
        it "does not send notification to user if user is event actor" do
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.motion_outcome!(@motion, @user)
        end
      end
      context "user has muted this type of event" do
        it "does not send notification to user" do
          @user.stub(:send_notification? => false)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.motion_outcome!(@motion, @actor)
        end
      end
    end
  end

  describe "motion_closed!" do
    context "sending notifications" do
      before do
        @group = stub_model(Group)
        @user = stub_model(User)
        @actor = stub_model(User, :send_notification? => true)
        @motion = stub_model(Motion, :group => @group, :author => @actor,
          :group_users => [@user, @actor], :closer => @actor)
        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end
      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true) }
        it "sends notification to user" do
          @notifications.should_receive(:create!).with(:user => @user)
          Event.motion_closed!(@motion, @actor)
        end
        it "does not send notification to user if user is event actor" do
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.motion_closed!(@motion, @user)
        end
      end
      context "user has muted this type of event" do
        before { @user.stub(:send_notification? => false) }
        it "does not send notification to user" do
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.motion_closed!(@motion, @actor)
        end
        it "does send notification if user is facilitator" do
          @notifications.should_receive(:create!).with(:user => @user)
          @motion.stub(:author => @user)
          Event.motion_closed!(@motion, @actor)
        end
      end
    end
  end

  describe "new_vote!" do
    context "sending notifications" do
      before do
        @actor = stub_model(User, :send_notification? => true)
        @user = stub_model(User)
        @m_author = stub_model(User, :send_notification? => true)
        @d_author = stub_model(User, :send_notification? => true)
        @group = stub_model(Group)
        @discussion = stub_model(Discussion, :group => @group)
        @motion = stub_model(Motion, :discussion => @discussion)
        @vote = stub_model(Vote, :user => @actor, :motion => @motion,
          :motion_author => @m_author, :discussion_author => @d_author,
          :group_users => [@user])
        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end
      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true) }
        it "sends notification to user if user is motion author" do
          @vote.stub(:motion_author => @user)
          @notifications.should_receive(:create!).with(:user => @user)
          Event.new_vote!(@vote)
        end
        it "sends notification to user if user is discussion author" do
          @vote.stub(:discussion_author => @user)
          @notifications.should_receive(:create!).with(:user => @user)
          Event.new_vote!(@vote)
        end
        context "user is motion author and discussion author" do
          before do
            @vote.stub(:motion_author => @user)
            @vote.stub(:discussion_author => @user)
          end
          it "only sends one notification" do
            @notifications.should_receive(:create!).with(:user => @user).exactly(:once)
            Event.new_vote!(@vote)
          end
          it "does not send notification to user if user is event actor" do
            @vote.stub(:user => @user)
            @notifications.should_not_receive(:create!).with(:user => @user)
            Event.new_vote!(@vote)
          end
        end
      end
      context "user has muted this type of event" do
        it "does not send notification to user" do
          @vote.stub(:motion_author => @user)
          @vote.stub(:discussion_author => @user)
          @user.stub(:send_notification? => false)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.new_vote!(@vote)
        end
      end
    end
  end

  describe "motion_blocked!" do
    context "sending notifications" do
      before do
        @group = stub_model(Group)
        @user = stub_model(User)
        @m_author = stub_model(User, :send_notification? => true)
        @actor = stub_model(User, :send_notification? => true)
        @motion = stub_model(Motion, :group => @group)
        @vote = stub_model(Vote, :user => @actor,
          :group => @group,
          :motion => @motion,
          :group_users => [@user, @m_author, @actor], 
          :motion_author => @m_author,
          :discussion_author => @m_author)

        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end
      context "user is subscribed to this type of event" do
        before { @user.stub(:send_notification? => true)}
        it "sends notification to user and author" do
          @notifications.should_receive(:create!).with(:user => @user)
          @notifications.should_receive(:create!).with(:user => @m_author)
          Event.motion_blocked!(@vote)
        end
        it "does not send notification to user if user is event actor" do
          @vote.stub(:user => @user)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.motion_blocked!(@vote)
        end
      end
      context "user has muted this type of event" do
        it "does not send notification to user" do
          @user.stub(:send_notification? => false)
          @notifications.should_not_receive(:create!).with(:user => @user)
          Event.motion_blocked!(@vote)
        end
      end
    end
  end

  describe "membership_requested!" do
    let(:group) { mock_model(Group)}
    let(:membership) { mock_model(Membership, :group_admins => [], :group => group) }
    subject { Event.membership_requested!(membership) }

    its(:kind) { should eq("membership_requested") }
    its(:eventable) { should eq(membership) }

    context "sending notifications" do
      before do
        @user, @admin1, @admin2 = create(:user), create(:user), create(:user)
        @group = create(:group)
        @group.add_admin! @admin1
        @group.add_admin! @admin2
        @membership = @group.add_request! @user
        @event = Event.membership_requested!(@membership)
      end

      it "notifies admins" do
        @event.notifications.where(:user_id => @admin1.id).
          should exist
        @event.notifications.where(:user_id => @admin2.id).
          should exist
      end
    end
  end

  describe "user_added_to_group!" do
    let(:membership) { create(:group).add_member! create(:user) }
    subject { Event.user_added_to_group!(membership) }

    its(:kind) { should eq("user_added_to_group") }
    its(:eventable) { should eq(membership) }

    context "sending notifications" do
      before do
        @group = create(:group)
        @user = create(:user)
        @membership = @group.add_member! @user
        @event = Event.user_added_to_group!(@membership)
      end

      it "notifies user" do
        @event.notifications.where(:user_id => @user.id).
          should exist
      end

      it "sends email to user" do
        UserMailer.should_receive(:added_to_group).with(@user, @group).
          and_return(stub(deliver: true))
        @event = Event.user_added_to_group!(@membership)
      end

      it "does not send email to user if user has not yet acctepted invitation
          to loomio" do
        @user = User.invite_and_notify!({ :email => "example@blah.com" },
                                        create(:user), @group)
        @membership = @user.memberships.first
        UserMailer.should_not_receive(:added_to_group)

        @event = Event.user_added_to_group!(@membership)
      end
    end
  end


  describe "comment_liked!" do
    context "sending notifications" do
      before do
        @user = stub_model(User)
        @actor = stub_model(User)
        @group = stub_model(Group)
        @discussion = stub_model(Discussion, :group => @group)
        @comment = stub_model(Comment, :discussion => @discussion)
        @comment_vote = stub_model(CommentVote, :comment => @comment)

        @notifications = double 'notifications'
        @event = stub_model(Event)
        @event.stub(:notifications => @notifications)
        Event.stub(:create!).and_return(@event)
      end

      it "notifies user" do
        @comment_vote.stub(:user => @actor, :comment_user => @user)
        @notifications.should_receive(:create!).with(:user => @user)
        Event.comment_liked!(@comment_vote)
      end

      it "does not notify user if user is event actor" do
        @comment_vote.stub(:user => @user, :comment_user => @user)
        @notifications.should_not_receive(:create!).with(:user => @user)
        Event.comment_liked!(@comment_vote)
      end
    end
  end
end
