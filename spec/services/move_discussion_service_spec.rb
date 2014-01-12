require_relative '../../app/services/move_discussion_service'

describe MoveDiscussionService do
  let(:discussion) { double(:discussion, group: source_group) }
  let(:source_group) { double(:source_group, admins: [], parent: nil) }
  let(:destination_group) { double(:destination_group, admins: [], parent: nil) }
  let(:user) { double(:user) }

  before do
    @mover = MoveDiscussionService.new(discussion: discussion,
                                       destination_group: destination_group,
                                       user: user)
  end

  context "#user_is_admin_of_source?" do
    subject { @mover.user_is_admin_of_source? }

    context "user is admin" do
      before { source_group.admins << user }
      it {should be_true}
    end

    context "user is not admin" do
      it {should be_false}
    end
  end

  context "#user_is_admin_of_destination?" do
    subject { @mover.user_is_admin_of_destination? }

    context "user is admin" do
      before { destination_group.admins << user }
      it {should be_true}
    end

    context "user is not admin" do
      it {should be_false}
    end
  end

  context "destination_group_is_related_to_source_group?" do
    subject { @mover.destination_group_is_related_to_source_group? }

    context "destination group is parent of source", focus: true do
      before do
        source_group.stub(:parent).and_return(destination_group)
      end
      it {should be_true}
    end

    context "destination group is sibling of source" do
      let(:parent_group) { double(:parent_group) }
      before do
        destination_group.stub(:parent).and_return(parent_group)
        source_group.stub(:parent).and_return(parent_group)
      end
      it {should be_true}
    end

    context "destination group is child of source" do
      before do
        destination_group.stub(:parent).and_return(source_group)
      end
      it {should be_true}
    end

    context "destination group is different family" do
      it {should be_false}
    end
  end

  context "valid?" do
    before do
      @mover.stub(:user_is_admin_of_source?).and_return(true)
      @mover.stub(:user_is_admin_of_destination?).and_return(true)
      @mover.stub(:destination_group_is_related_to_source_group?).and_return(true)
    end

    subject do
      @mover.valid?
    end

    context "user is not admin of source" do
      before do
        @mover.stub(:user_is_admin_of_source?).and_return(false)
      end
      it {should be_false}
    end

    context "user is not admin of destination" do
      before do
        @mover.stub(:user_is_admin_of_destination?).and_return(false)
      end
      it {should be_false}
    end

    context "destination group does not belong to source" do
      before do
        @mover.stub(:destination_group_is_related_to_source_group?).and_return(false)
      end
      it {should be_false}
    end

    context "all conditions are true" do
      it {should be_true}
    end
  end

  context "move is valid" do
    before do
      @mover.should_receive(:valid?).and_return(true)
      discussion.stub(:group=){ discussion.stub(:group).and_return destination_group}
      discussion.stub(:public?).and_return(true)
      destination_group.stub(:is_hidden?).and_return(false)
    end

    it "moves the discussion from source to destination" do
      discussion.should_receive(:save!)
      @mover.move!
      discussion.group.should == destination_group
    end
  end

end
