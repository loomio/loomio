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
      @previous_url = motion_url(@motion)
      @vote_args = { motion_id: @motion.id,
                   vote: {position: 'yes', statement: 'blah'} }
      request.env["HTTP_REFERER"] = @previous_url
    end

    context 'during voting phase' do

      describe "casting a vote" do
        it 'redirects to previous url' do
          post :create, @vote_args
          response.should redirect_to(@previous_url)
        end
        it "assigns flash success message" do
          post :create, @vote_args
          flash[:success].should =~ /Position submitted/
        end
        it "assigns instance variables for the view" do
          post :create, @vote_args
          assigns(:vote).user.should == @user
          assigns(:vote).motion.should == @motion
          assigns(:vote).position.should == 'yes'
          assigns(:vote).statement.should == 'blah'
        end
        it "fires new_vote event" do
          Event.should_receive(:new_vote!)
          post :create, @vote_args
        end
      end

      describe "casting a 'block' vote" do
        it "fires motion_blocked event" do
          Event.should_receive(:motion_blocked!)
          post :create, motion_id: @motion.id,
                   vote: { position: 'block' }
        end
      end

      describe "updating a vote" do
        before do
          @vote = Vote.new(position: 'yes')
          @vote.motion = @motion
          @vote.user = @user
          @vote.save!
          @vote_args = {  motion_id: @motion.id, id: @vote.id,
               vote: {position: 'no', statement: 'blah'} }
        end
        it 'creates a new vote' do
          post :update, @vote_args

          Vote.all.count.should == 2
          @user.get_vote_for(@motion).position.should == 'no'
        end
        it "assigns flash success message" do
          post :update, @vote_args
          flash[:success].should =~ /Vote updated/
        end
        it "redirects to motion discussion" do
          post :update, @vote_args
          response.should redirect_to(@motion.discussion)
        end
        it "fires new_vote event" do
          Event.should_receive(:new_vote!)
          post :update, @vote_args
        end
      end

      describe "deleting a vote" do
        before do
          vote = Vote.new(position: 'yes')
          vote.motion = @motion
          vote.user = @user
          vote.save!
          delete :destroy, id: vote.id, motion_id: @motion.id
        end
        it 'redirects to discussion page' do
          response.should redirect_to(@motion.discussion)
        end
        it "gives flash notice" do
          flash[:notice].should =~ /destroyed/
        end
        it "destroys the vote" do
          Vote.all.count.should == 0
        end
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
        flash[:error].should =~ /This proposal has closed. You can no longer decide on it/
      end
    end
  end
end
