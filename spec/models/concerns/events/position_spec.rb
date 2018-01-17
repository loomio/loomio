require "rails_helper"

describe "Events::Position" do
  let(:group) { FactoryBot.create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:comment1) { create :comment, discussion: discussion }
  let(:comment2) { create :comment, discussion: discussion }
  let(:comment3) { create :comment, discussion: discussion }
  let!(:created_event) { create :event, kind: :discussion_created, eventable: discussion }

  it "gives events with a parent_id a pos sequence" do
    e1 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment2)
    e3 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment3)
    expect(e1.reload.position).to be 1
    expect(e2.reload.position).to be 2
    expect(e3.reload.position).to be 3
  end

  it "reorders if parent changes" do
    e1 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent: nil, discussion: discussion, eventable: comment2)
    expect(e1.reload.position).to be 1
    e2.update(parent: created_event)
    expect(e2.reload.position).to be 2
  end

  it "removes position if discussion_id is dropped" do
    e1 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment2)
    e3 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment3)
    expect(e1.reload.position).to be 1
    expect(e2.reload.position).to be 2
    expect(e3.reload.position).to be 3
    e2.update(discussion_id: nil)
    expect(e3.reload.position).to be 2
  end

  it "handles destroy" do
    e1 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment1)
    e2 = Event.create(kind: "new_comment", parent: created_event, discussion: discussion, eventable: comment2)
    expect(e1.reload.position).to be 1
    expect(e2.reload.position).to be 2
    e1.destroy
    expect(e2.reload.position).to be 1
  end
end
