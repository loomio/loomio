require 'rails_helper'

describe DiscussionsController do
  let(:app_controller) { controller }
  let(:user) { FactoryGirl.create(:user) }
  let(:motion) { mock_model(Motion).as_null_object }
  let(:group) { create :group }
  let(:discussion) { stub_model(Discussion,
                                title: "Top ten",
                                key: 'abc123',
                                author: user,
                                current_motion: motion,
                                private: true,
                                group: group) }

  context "authenticated user" do
    before do
      sign_in user
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:cannot?).with(:show, group).and_return(false)
      Discussion.stub_chain(:published, :find_by_key!).with(discussion.key).and_return(discussion)
      User.stub(:find).and_return(user)
      Group.stub(:find).with(group.key).and_return(group)
    end

    context "deleting a discussion" do
      before do
        discussion.stub(:delayed_destroy)
        # controller.stub(:authorize!).with(:destroy, discussion).and_return(true)
      end
      it "destroys discussion" do
        discussion.should_receive(:delayed_destroy)
        delete :destroy, id: discussion.key
      end
      it "redirects to group" do
        delete :destroy, id: discussion.key
        response.should redirect_to(group)
      end
      it "gives flash success message" do
        delete :destroy, id: discussion.key
        flash[:success].should =~ /Discussion successfully deleted/
      end
    end

    describe "creating a new proposal" do
      context "current proposal already exists" do
        it "redirects to the discussion page" do
          get :new_proposal, id: discussion.key
          response.should redirect_to(discussion)
        end
        it "displays a proposal already exists message" do
          get :new_proposal, id: discussion.key
          flash[:notice].should =~ /A current proposal already exists for this disscussion./
        end
      end
      context "where no current proposal exists" do
        before do
          discussion.stub(current_motion: nil)
          # Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
          get :new_proposal, id: discussion.key
        end
        it "succeeds" do
          response.should be_success
        end
        it "renders new motion template" do
          get :new_proposal, id: discussion.key
          response.should render_template("motions/new")
        end
      end
    end

    describe "add_comment" do
      let(:comment) { double(:comment).as_null_object }
      before do
        Discussion.stub(:find).and_return(discussion)
        DiscussionService.stub(:add_comment)
        Event.stub(:new_comment!)
        Comment.stub(:new).and_return(comment)
      end

      context 'invalid comment' do
        it 'does not add a comment' do
          DiscussionService.should_receive(:add_comment).and_return(false)
          user.should_not_receive(:update_attributes)
          xhr :post, :add_comment, comment: "", id: discussion.key, uses_markdown: false
        end
      end

      context 'valid comment' do
        it 'adds a comment' do
          DiscussionService.should_receive(:add_comment).
            with(comment).and_return(true)
          user.should_receive(:update_attributes)
          xhr :post, :add_comment, comment: "", id: discussion.key, uses_markdown: false, attachments: [2]
        end
      end
    end

    describe "change version" do
      before do
        @version_item = mock_model(Discussion, :title => 'most important discussion', :description => "new version", key: 'abc1234', :save! => true)
        @version = mock_model(PaperTrail::Version, :item => discussion)
        PaperTrail::Version.stub(:find).and_return(@version)
        @version.stub(:reify).and_return(@version_item)
        @version.stub(:save!)
      end

      it "calls reify on version" do
        @version.should_receive(:reify)
        post :update_version, :version_id => @version.id
      end

      it "saves the reified version" do
        @version_item.should_receive(:save!)
        post :update_version, :version_id => @version.id
      end

      it "renders the JS template" do
        post :update_version, :version_id => @version.id
        response.should be_redirect
      end
    end
  end
end
