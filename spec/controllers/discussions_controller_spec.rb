require 'spec_helper'

describe DiscussionsController do
  let(:app_controller) { controller }
  let(:user) { stub_model(User) }
  let(:motion) { mock_model(Motion) }
  let(:group) { mock_model(Group) }
  let(:discussion) { stub_model(Discussion,
                                title: "Top ten",
                                author: user,
                                current_motion: motion,
                                group: group) }

  context "authenticated user" do
    before do
      sign_in user
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:cannot?).with(:show, group).and_return(false)
      Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
      Discussion.stub(:new).and_return(discussion)
      User.stub(:find).and_return(user)
      Group.stub(:find).with(group.id.to_s).and_return(group)
    end

    describe "creating a discussion" do
      before do
        discussion.stub(:add_comment)
        discussion.stub(:save).and_return(true)
        discussion.stub(:group_users_without_discussion_author).and_return([])
        DiscussionMailer.stub(:spam_new_discussion_created)
        user.stub_chain(:ability, :authorize!).and_return(true)
        @discussion_hash = { group_id: group.id, title: "Shinney" }
      end
      it "does not send email by default" do
        DiscussionMailer.should_not_receive(:spam_new_discussion_created)
        get :create, discussion: @discussion_hash
      end

      it "displays flash success message" do
        get :create, discussion: @discussion_hash
        flash[:success].should match(I18n.t("success.discussion_created"))
      end

      it "redirects to discussion" do
        get :create, discussion: @discussion_hash
        response.should redirect_to(discussion_path(discussion.id))
      end
    end

    context "deleting a discussion" do
      before do
        discussion.stub(:delayed_destroy)
        # controller.stub(:authorize!).with(:destroy, discussion).and_return(true)
      end
      it "destroys discussion" do
        discussion.should_receive(:delayed_destroy)
        delete :destroy, id: discussion.id
      end
      it "redirects to group" do
        delete :destroy, id: discussion.id
        response.should redirect_to(group)
      end
      it "gives flash success message" do
        delete :destroy, id: discussion.id
        flash[:success].should =~ /Discussion successfully deleted/
      end
    end

    context "moving a discussion" do
      before do
        group = create :group
        Group.stub(:find).and_return(group)
        DiscussionMover.stub(:can_move?).and_return(true)
      end
      it "moves the discussion to the selected group" do
        discussion.should_receive(:group_id=).with(group.id.to_s)
        put :move, id: discussion.id, discussion: { group_id: group.id }
      end
      it "redirects to the discussion" do
        put :move, id: discussion.id, discussion: { group_id: group.id }
        response.should redirect_to(discussion)
      end
      it "gives flash success message" do
        put :move, id: discussion.id, discussion: { group_id: group.id }
        flash[:success].should =~ /Discussion successfully moved./
      end
    end

    describe "creating a new proposal" do
      context "current proposal already exists" do
        it "redirects to the discussion page" do
          get :new_proposal, id: discussion.id
          response.should redirect_to(discussion)
        end
        it "displays a proposal already exists message" do
          get :new_proposal, id: discussion.id
          flash[:notice].should =~ /A current proposal already exists for this disscussion./
        end
      end
      context "where no current proposal exists" do
        before do
          discussion.stub(current_motion: nil)
          Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
          get :new_proposal, id: discussion.id
        end
        it "succeeds" do
          response.should be_success
        end
        it "renders new motion template" do
          get :new_proposal, id: discussion.id
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
          xhr :post, :add_comment, comment: "", id: discussion.id, uses_markdown: false
        end
      end

      context 'valid comment' do
        it 'adds a comment' do
          DiscussionService.should_receive(:add_comment).
            with(comment).and_return(true)
          user.should_receive(:update_attributes)
          xhr :post, :add_comment, comment: "", id: discussion.id, uses_markdown: false, attachments: [2]
        end
      end
    end

    describe "edit description" do
      before do
        discussion.stub(:set_edit_description_activity!)
        discussion.stub(:save!)
      end

      after do
        post :update_description, :id => discussion.id, :description => "blah"
      end

      it "assigns description to the model" do
        discussion.should_receive(:set_description!)
      end
    end

    describe "edit title" do
      before do
        discussion.stub(:save!)
      end

      after do
        xhr :post, :edit_title,
          :id => discussion.id,
          :title => "The Butterflys"
      end

      it "assigns title to the model" do
        discussion.should_receive(:title=).with "The Butterflys"
      end
      it "saves the model" do
        discussion.should_receive :save!
      end
      it "creates activity in the events table" do
        discussion.should_receive :fire_edit_title_event
      end
    end

    describe "change version" do
      before do
        @version_item = mock_model(Discussion, :description => "new version", :save! => true)
        @version = mock_model(Version, :item => discussion)
        Version.stub(:find).and_return(@version)
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
