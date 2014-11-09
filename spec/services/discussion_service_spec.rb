require 'rails_helper'

describe 'DiscussionService' do
  let(:ability) { double(:ability, :authorize! => true, can?: true) }
  let(:user) { double(:user, ability: ability, update_attributes: true) }
  let(:discussion) { double(:discussion, author: user,
                                         'author=' => user,
                                         save!: true,
                                         valid?: true,
                                         title_changed?: false,
                                         description_changed?: false,
                                         :title= => true,
                                         :description= => true,
                                         :private= => true,
                                         :uses_markdown= => true,
                                         inherit_group_privacy!: nil,
                                         uses_markdown: true,
                                         :iframe_src= => true,
                                         update_attribute: true,
                                         update_attributes: true,
                                         group: true,
                                         private: true,
                                         created_at: Time.now) }
  let(:comment) { double(:comment,
                         save!: true,
                         valid?: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         destroy: true,
                         author: user) }
  let(:event) { double(:event) }
  let(:discussion_reader) { double(:discussion_reader, follow!: true, viewed!: true) }
  let(:discussion_params) { {title: "new title", description: "", private: true, uses_markdown: true} }


  before do
    Events::NewDiscussion.stub(:publish!).and_return(event)
    allow(DiscussionReader).to receive(:for) { discussion_reader }
  end


  describe 'create' do
    it 'authorizes the user can create the discussion' do
      ability.should_receive(:authorize!).with(:create, discussion)
      DiscussionService.create(discussion: discussion,
                               actor: user)
    end

    it 'saves the discussion' do
      discussion.should_receive(:save!).and_return(true)
      DiscussionService.create(discussion: discussion,
                               actor: user)
    end

    context 'the discussion is valid' do
      before { discussion.stub(:valid?).and_return(true) }

      it 'fires a NewDiscussion event' do
        Events::NewDiscussion.should_receive(:publish!).with(discussion).and_return(true)
        DiscussionService.create(discussion: discussion,
                                 actor: user)
      end

      it 'returns the event created' do
        DiscussionService.create(discussion: discussion,
                                 actor: user).should == event
      end
    end
  end

  describe 'update' do
    it 'authorizes the user can update the discussion' do
      ability.should_receive(:authorize!).with(:update, discussion)

      DiscussionService.update discussion: discussion,
                               params: discussion_params,
                               actor: user
    end

    it 'sets params' do
      discussion.should_receive(:private=).with(discussion_params[:private])
      discussion.should_receive(:title=).with(discussion_params[:title])
      discussion.should_receive(:description=).with(discussion_params[:description])
      discussion.should_receive(:uses_markdown=).with(discussion_params[:uses_markdown])

      DiscussionService.update discussion: discussion,
                               params: discussion_params,
                               actor: user
    end

    it 'saves the discussion' do
      discussion.should_receive(:save!).and_return(true)
      DiscussionService.update discussion: discussion,
                               params: discussion_params,
                               actor: user
    end

    context 'the discussion is valid' do
      before { discussion.stub(:valid?).and_return(true) }

      it 'updates user markdown-preference' do
        user.should_receive(:update_attributes).with(uses_markdown: discussion.uses_markdown).and_return(true)
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
      end
    end

    context 'the discussion is invalid' do
      before { discussion.stub(:valid?).and_return(false) }
      it 'returns false' do
        DiscussionService.update(discussion: discussion,
                                 params: discussion_params,
                                 actor: user).should == false
      end
    end
  end
end
