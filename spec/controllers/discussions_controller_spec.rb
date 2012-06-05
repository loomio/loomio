require 'spec_helper'

describe DiscussionsController do
  let(:app_controller) { controller }
  let(:user) { stub_model(User) }
  let(:motion) { mock_model(Motion) }
  let(:group) { mock_model(Group) }
  let(:discussion) { stub_model(Discussion,
                                author: user,
                                current_motion: motion,
                                group: group) }

  context "authenticated user" do
    before do
      sign_in user
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:resource).and_return(discussion)
      Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
      Discussion.stub(:new).and_return(discussion)
      Group.stub(:find).with(group.id.to_s).and_return(group)
      group.stub(:can_be_viewed_by?).with(user).and_return(true)
      group.stub_chain(:users, :include?).with(user).and_return(true)
    end

    context "views a discussion" do
      before do
        motion.stub(:votes_graph_ready).and_return([])
        motion.stub(:user_has_voted?).and_return(true)
        motion.stub(:open_close_motion)
        motion.stub(:voting?).and_return(true)
        discussion.stub(:history)
      end
      it "responds with success" do
        get :show, id: discussion.id
        response.should be_success
      end

      it "assigns array with discussion history" do
        discussion.should_receive(:history).and_return(['fake'])
        get :show, id: discussion.id
        assigns(:history).should eq(['fake'])
      end
    end

    context "creates a discussion" do
      before do
        discussion.stub(:add_comment)
        discussion.stub(:save).and_return(true)
        DiscussionMailer.stub(:spam_new_discussion_created)
      end
      it "does not send email by default" do
        DiscussionMailer.should_not_receive(:spam_new_discussion_created)
        get :create, discussion: { group_id: group.id, title: "Shinney",
                                   comment: "Bright light" }
      end
      it "sends email if notify_group_upon_creation is passed in params" do
        DiscussionMailer.should_receive(:spam_new_discussion_created).
          with(discussion)
        get :create, discussion: { group_id: group.id, title: "Shinney",
                                   comment: "Bright light",
                                   notify_group_upon_creation: 1 }
      end
      it "adds comment" do
        discussion.should_receive(:add_comment).with(user, "Bright light")
        get :create, discussion: { group_id: group.id, title: "Shinney",
                                   comment: "Bright light" }
      end
      it "displays flash success message" do
        get :create, discussion: { group_id: group.id, title: "Shinney",
                                   comment: "Bright light" }
        flash[:success].should match("Discussion sucessfully created.")
      end
      it "redirects to discussion" do
        get :create, discussion: { group_id: group.id, title: "Shinney",
                                   comment: "Bright light" }
        response.should redirect_to(discussion_path(discussion.id))
      end
    end

    context "creates a new proposal" do
      it "is successful" do
        get :new_proposal, id: discussion.id
        response.should be_success
      end
      it "renders new motion template" do
        get :new_proposal, id: discussion.id
        response.should render_template("motions/new")
      end
    end

    context "adds comment" do
      before do
        discussion.stub(:add_comment)
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        post :add_comment, comment: "Hello!", id: discussion.id
      end

      it "adds comment" do
        discussion.should_receive(:add_comment).with(user, "Hello!")
        post :add_comment, comment: "Hello!", id: discussion.id
      end

      it "redirects to the discussion" do
        post :add_comment, comment: "Hello!", id: discussion.id
        response.should redirect_to(discussion_url(discussion))
      end
    end
  end
end
