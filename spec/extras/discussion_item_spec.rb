describe DiscussionItem do
  describe "initialize" do
    let(:event) { stub(:event) }

    context "event is for a new discussion" do
      it "delagates to a NewDiscussion discussion item" do
        event.stub(:kind).and_return("new_discussion")
        event.stub(:eventable).and_return(stub(:Discussion))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::NewDiscussion
      end
    end

    context "event is for a new motion" do
      it "delagates to a NewMotion discussion item" do
        event.stub(:kind).and_return("new_motion")
        event.stub(:eventable).and_return(stub(:Motion))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::NewMotion
      end
    end

    context "event is for a new vote" do
      it "delagates to a NewVote discussion item" do
        event.stub(:kind).and_return("new_vote")
        event.stub(:eventable).and_return(stub(:Vote))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::NewVote
      end
    end

    context "event is for edited motion" do
      it "delagates to a MotionEdited discussion item" do
        event.stub(:kind).and_return("motion_edited")
        event.stub(:eventable).and_return(stub(:Motion))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::MotionEdited
      end
    end

    context "event is for closed motion" do
      it "delagates to a MotionClosed discussion item" do
        event.stub(:kind).and_return("motion_closed")
        event.stub(:eventable).and_return(stub(:Motion))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::MotionClosed
      end
    end

    context "event is for blocked motion" do
      it "delagates to a NewVote discussion item" do
        event.stub(:kind).and_return("motion_blocked")
        event.stub(:eventable).and_return(stub(:Vote))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::NewVote
      end
    end

    context "event is for a editing the discussion title" do
      it "delagates to a DiscussionTitleEdited discussion item" do
        event.stub(:kind).and_return("discussion_title_edited")
        event.stub(:eventable).and_return(stub(:Motion))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::DiscussionTitleEdited
      end
    end

    context "event is for a editing the discussion title" do
      it "delagates to a DiscussionDescriptionEdited discussion item" do
        event.stub(:kind).and_return("discussion_description_edited")
        event.stub(:eventable).and_return(stub(:Motion))
        DiscussionItem.new(event).
          item.class.should == DiscussionItems::DiscussionDescriptionEdited
      end
    end

  end
end
