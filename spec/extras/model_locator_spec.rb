require 'rails_helper'

describe ModelLocator do
  describe "locate" do

    let (:discussion) { create :discussion }

    before { discussion }


    it "finds a model when the param model_id is present" do
      expect(ModelLocator.new(:discussion, discussion_id: discussion.id).locate).to eq discussion
    end

    it "finds a model when the param model_key is present" do
      expect(ModelLocator.new(:discussion, discussion_key: discussion.key).locate).to eq discussion
    end

    it "finds a model when the param id is present" do
      expect(ModelLocator.new(:discussion, id: discussion.id).locate).to eq discussion
    end

    it "finds a model with an aggregate model name" do
      application = create(:application)
      expect(ModelLocator.new(:oauth_application, id: application.id).locate).to eq application
    end
  end
end
