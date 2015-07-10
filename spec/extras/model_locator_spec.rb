require 'rails_helper'

describe ModelLocator do
  describe "locate" do

    let (:discussion) { create :discussion }
    let (:motion) { create :motion }
    let (:comment) { create :comment }
    let (:membership_request) { create :membership_request }

    before { discussion; motion }


    it "finds a model when the param model_id is present" do
      expect(ModelLocator.new(:discussion, discussion_id: discussion.id).locate).to eq discussion
    end

    it "finds a model when the param model_key is present" do
      expect(ModelLocator.new(:discussion, discussion_key: discussion.key).locate).to eq discussion
    end

    it "finds a model when the param id is present" do
      expect(ModelLocator.new(:discussion, id: discussion.id).locate).to eq discussion
    end

    it "finds an alternate model by model_id" do
      expect(ModelLocator.new(:motion, motion_id: motion.id).locate).to eq motion
    end

    it "finds an alternate model by key" do
      expect(ModelLocator.new(:motion, motion_key: motion.key).locate).to eq motion
    end

    it "finds an alternate model by id" do
      expect(ModelLocator.new(:motion, id: motion.id).locate).to eq motion
    end

    it 'finds a model which does not use friendly ids' do
      expect(ModelLocator.new(:comment, id: comment.id).locate).to eq comment
    end

    it 'finds a model with a complex name' do
      expect(ModelLocator.new(:membership_request, id: membership_request.id).locate).to eq membership_request
    end
  end
end
