require 'spec_helper'

describe VotesController do
  context 'a signed in user voting on a motion' do
    before :each do
      @user = User.make
      @user.save
      sign_in @user
      @group = Group.make
      @group.save
      @group.add_member!(@user)
      @discussion = create_discussion(group: @group)
      @motion = create_motion(discussion: @discussion, phase: 'voting')
      @motion.save!
    end
    context 'during voting phase' do
      it 'can vote' do
        request.env["HTTP_REFERER"] = motion_url(@motion)
        post :create, motion_id: @motion.id,
             vote: {position: 'yes', statement: 'blah'}
        response.should be_redirect
        flash[:success].should =~ /Your vote has been submitted/
        assigns(:vote).user.should == @user
        assigns(:vote).motion.should == @motion
        assigns(:vote).position.should == 'yes'
        assigns(:vote).statement.should == 'blah'
      end

      it 'update vote creates a new vote' do
        vote = Vote.new(position: 'yes')
        vote.motion = @motion
        vote.user = @user
        vote.save!

        post :update, motion_id: @motion.id, id: vote.id,
             vote: {position: 'no', statement: 'blah'}

        response.should be_redirect
        flash[:success].should =~ /Vote updated/
        Vote.all.count.should == 2
        @user.get_vote_for(@motion).position.should == 'no'
      end

      it 'can delete vote' do
        vote = Vote.new(position: 'yes')
        vote.motion = @motion
        vote.user = @user
        vote.save!
        delete :destroy, id: vote.id, motion_id: @motion.id
        response.should be_redirect
        flash[:notice].should =~ /destroyed/
        Vote.all.count.should == 0
      end
    end

    context 'during closed phase' do
      before :each do
        @discussion = create_discussion(group: @group, author: @user)
        @motion = create_motion(discussion: @discussion, phase: 'closed')
      end

      it 'cannot vote' do
        post :create, motion_id: @motion.id,
             vote: {position: 'yes', statement: 'blah'}
        response.should be_redirect
        flash[:error].should =~ /Can only vote in voting phase/
      end
    end
  end
end
