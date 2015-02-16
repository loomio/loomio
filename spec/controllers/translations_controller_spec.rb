require 'rails_helper'

describe TranslationsController do
  let(:app_controller) { controller }
  let(:discussion) { create :discussion }
  let(:translation) { create :translation, translatable: discussion }
  let(:comment) { create :comment, discussion: discussion }
  let(:motion) { create :motion, discussion: discussion }
  let(:vote) { create :vote, motion: motion }

  context "translation" do
    before do
      app_controller.stub(:authorize!).and_return(true)
      TranslationService.any_instance.stub(:translate).and_return(translation)
      TranslationService.stub(:available?).and_return(true)
      Discussion.stub(:find_by_key!).and_return(discussion)
    end

    it "successfully translates a comment" do
      post :create, model: :comment, id: comment.id, format: :js
      response.should render_template "comments/comment_translations"
      response.should be_successful
    end

    it "successfully translates a discussion" do
      post :create, model: :discussion, id: discussion.id, format: :js
      response.should render_template "discussions/discussion_translations"
      response.should be_successful
    end

    it "successfully translates a vote" do
      post :create, model: :vote, id: vote.id, format: :js
      response.should render_template "votes/vote_translations"
      response.should be_successful
    end

    it "successfully translates a motion" do
      post :create, model: :motion, id: motion.id, format: :js    
      response.should render_template "motions/motion_translations"
      response.should be_successful
    end

    it "does not translate when passed a bogus model" do
      post :create, model: :bogus, id: comment.id, format: :js
      expect(response.body.strip).to eq  ""
      expect(response.status).to eq  400
    end
  end
end
