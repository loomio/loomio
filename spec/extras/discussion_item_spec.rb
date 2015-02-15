require 'rails_helper'

describe DiscussionItem do
  describe "initialize" do
    let(:event) { double(:event) }

    context "event is for a new discussion" do
      it "delagates to a NewDiscussion discussion item" do
        event.stub(:kind).and_return("new_discussion")
        event.stub(:eventable).and_return(double(:Discussion))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::NewDiscussion
      end
    end

    context "event is for a new motion" do
      it "delagates to a NewMotion discussion item" do
        event.stub(:kind).and_return("new_motion")
        event.stub(:eventable).and_return(double(:Motion))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::NewMotion
      end
    end

    context "event is for a new vote" do
      it "delagates to a NewVote discussion item" do
        event.stub(:kind).and_return("new_vote")
        event.stub(:eventable).and_return(double(:Vote))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::NewVote
      end
    end

    context "event is for closed motion" do
      it "delagates to a MotionClosed discussion item" do
        event.stub(:kind).and_return("motion_closed")
        event.stub(:eventable).and_return(double(:Motion))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::MotionClosed
      end
    end

    context "event is for a editing the motion close date" do
      it "delagates to a MotionCloseDateEdited discussion item" do
        event.stub(:kind).and_return("motion_close_date_edited")
        event.stub(:eventable).and_return(double(:Motion))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::MotionCloseDateEdited
      end
    end

    context "event is for a editing the discussion title" do
      it "delagates to a DiscussionTitleEdited discussion item" do
        event.stub(:kind).and_return("discussion_title_edited")
        event.stub(:eventable).and_return(double(:Motion))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::DiscussionTitleEdited
      end
    end

    context "event is for a editing the discussion title" do
      it "delagates to a DiscussionDescriptionEdited discussion item" do
        event.stub(:kind).and_return("discussion_description_edited")
        event.stub(:eventable).and_return(double(:Motion))
        expect(DiscussionItem.new(event).
          item.class).to eq DiscussionItems::DiscussionDescriptionEdited
      end
    end

  end
end
