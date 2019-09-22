require "rails_helper"

describe "Events::Position" do
  let(:group) { FactoryBot.create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:comment1) { create :comment, discussion: discussion }
  let(:comment2) { create :comment, discussion: discussion }
  let(:comment3) { create :comment, discussion: discussion }

  it "gives events with a parent_id a pos sequence" do
    e1 = Event.create(kind: "new_comment", parent: discussion.created_event, discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent: discussion.created_event, discussion: discussion, eventable: comment2)
    e3 = Event.create(kind: "new_comment", parent: discussion.created_event, discussion: discussion, eventable: comment3)
    expect(e1.reload.position).to eq 1
    expect(e2.reload.position).to eq 2
    expect(e3.reload.position).to eq 3
  end

  describe 'depth' do
    let(:comment1) { create :comment, discussion: discussion }
    let(:comment2) { create :comment, discussion: discussion, parent: comment1 }
    let(:comment3) { create :comment, discussion: discussion, parent: comment2 }

    it "enforces max depth 2 " do
      e1 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment1)
      e2 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment2)
      e3 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment3)
      expect(e1.reload.depth).to eq 1
      expect(e2.reload.depth).to eq 2
      expect(e3.reload.depth).to eq 2
    end

    it "enforces max depth 1 " do
      discussion.update(max_depth: 1)
      e1 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment1)
      e2 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment2)
      e3 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment3)
      expect(e1.reload.depth).to eq 1
      expect(e2.reload.depth).to eq 1
      expect(e3.reload.depth).to eq 1
    end

    it "enforces max depth 3 " do
      discussion.update(max_depth: 3)
      e1 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment1)
      e2 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment2)
      e3 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment3)
      expect(e1.reload.depth).to eq 1
      expect(e2.reload.depth).to eq 2
      expect(e3.reload.depth).to eq 3
    end
  end

  it "reorders if parent changes" do
    e1 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment2)
    expect(e1.reload.position).to eq 1
    expect(e2.reload.position).to eq 2
  end

  it "removes position if discussion_id is dropped" do
    e1 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment2)
    e3 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment3)
    expect(e1.reload.position).to eq 1
    expect(e2.reload.position).to eq 2
    expect(e3.reload.position).to eq 3
    e2.update(discussion_id: nil)
    expect(e3.reload.position).to eq 2
  end

  it "handles destroy" do
    e1 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", discussion: discussion, eventable: comment2)
    expect(e1.reload.position).to eq 1
    expect(e2.reload.position).to eq 2
    e1.destroy
    expect(e2.reload.position).to eq 1
  end
end
