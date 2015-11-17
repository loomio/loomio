require "rails_helper"

describe DiscussionItems::DiscussionDescriptionEdited do
  let(:event) { double(:event) }
  let(:discussion) { double(:discussion) }
  let(:item) { DiscussionItems::DiscussionDescriptionEdited.new(event, discussion) }

  it "#actor returns the user who edited the description" do
    actor = double(:actor)
    item.stub_chain(:event, :user).and_return(actor)
    expect(item.actor).to eq item.event.user
  end

  it "#header returns a string" do
    expect(item.header).to eq I18n.t('discussion_items.discussion_description_edited')
  end

  it "#group returns the discussion's group" do
    item.stub_chain(:discussion, :group).and_return("goob")
    expect(item.group).to eq item.discussion.group
  end

  it "#time returns the time the discription's title was edited" do
    item.stub_chain(:event, :created_at).and_return("blah")
    expect(item.time).to eq item.event.created_at
  end
end
