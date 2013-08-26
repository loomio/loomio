require 'spec_helper'

describe VotesController do
  context 'a signed in user voting on a motion' do
    before :each do
      @user = create(:user)
      sign_in @user
      @group = create(:group)
      @group.add_member!(@user)
      @discussion = create(:discussion, group: @group)
      @motion = create(:motion, discussion: @discussion)
      @motion.save!
      @previous_url = motion_url(@motion)
      @vote_args = { motion_id: @motion.id,
                   vote: {position: 'yes', statement: 'blah'} }
      request.env["HTTP_REFERER"] = @previous_url
    end

    context 'proposal is open' do

      describe "casting a vote", focus: true do
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
          Events::NewVote.should_receive(:publish!)
          post :create, @vote_args
        end
      end

      describe "casting a 'block' vote" do
        it "fires motion_blocked event" do
          Events::MotionBlocked.should_receive(:publish!)
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
          flash[:success].should =~ /Position updated/
        end
        it "redirects to motion discussion" do
          post :update, @vote_args
          response.should redirect_to(@motion.discussion)
        end
        it "fires new_vote event" do
          Events::NewVote.should_receive(:publish!)
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

    context 'proposal is closed' do
      before :each do
        @discussion = create(:discussion, group: @group, author: @user)
        @motion = create(:motion, discussion: @discussion, closed_at: 2.days.ago)
      end

      it 'cannot vote' do
        post :create, motion_id: @motion.id,
             vote: {position: 'yes', statement: 'blah'}
        response.should be_redirect
        flash[:error].should =~ /This proposal has closed./
      end
    end
  end
end
