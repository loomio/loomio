require 'rails_helper'

describe 'DiscussionService' do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:discussion) { create(:discussion, author: user) }
  let(:comment) { double(:comment,
                         save!: true,
                         valid?: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         destroy: true,
                         author: user) }
  let(:event) { double(:event) }
  let(:discussion_params) { {title: "new title", description: "new description", private: true, uses_markdown: true} }


  before do
    Events::NewDiscussion.stub(:publish!).and_return(event)
  end


  describe 'create' do
    it 'authorizes the user can create the discussion' do
      user.ability.should_receive(:authorize!).with(:create, discussion)
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

      it 'syncs the discussion search vector' do
        ThreadSearchService.should_receive(:index!).with(discussion.id)
        DiscussionService.create(discussion: discussion,
                                 actor: user)
      end

      it 'fires a NewDiscussion event' do
        Events::NewDiscussion.should_receive(:publish!).with(discussion).and_return(true)
        DiscussionService.create(discussion: discussion,
                                 actor: user)
      end

      it 'returns the event created' do
        expect(DiscussionService.create(discussion: discussion,
                                 actor: user)).to eq event
      end
    end
  end

  describe 'update' do
    it 'authorizes the user can update the discussion' do
      user.ability.should_receive(:authorize!).with(:update, discussion)

      DiscussionService.update discussion: discussion,
                               params: discussion_params,
                               actor: user
    end

    it 'sets params' do
      discussion.should_receive(:private=).with(discussion_params[:private])
      discussion.should_receive(:title=).with(discussion_params[:title])
      discussion.should_receive(:description=).with(discussion_params[:description])

      DiscussionService.update discussion: discussion,
                               params: discussion_params,
                               actor: user
    end

    context 'the discussion is valid' do
      before { discussion.stub(:valid?).and_return(true) }

      it 'updates user markdown-preference' do
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
      end

      it 'publishes a discussion edited event' do
        expect(Events::DiscussionEdited).to receive :publish!
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
      end

      it 'syncs the discussion search vector' do
        ThreadSearchService.should_receive(:index!).with(discussion.id)
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
      end
    end

    context 'the discussion is invalid' do
      before { discussion.stub(:valid?).and_return(false) }
      it 'returns false' do
        expect(DiscussionService.update(discussion: discussion,
                                 params: discussion_params,
                                 actor: user)).to be false
      end
    end
  end

  describe 'update_reader' do
    context 'success' do
      it 'can save reader attributes' do
        DiscussionService.update_reader discussion: discussion,
                                        params: { starred: true },
                                        actor: user
        expect(DiscussionReader.for(user: user, discussion: discussion).starred).to eq true
      end
    end

    it 'does not update if the user cannot update the reader' do
      another_discussion = create(:discussion)
      expect { DiscussionService.update_reader discussion: another_discussion, params: { starred: true }, actor: user }.to raise_error CanCan::AccessDenied
      expect(DiscussionReader.for(user: user, discussion: another_discussion).starred).to eq false
    end
  end

  describe 'destroy' do

    it 'checks the actor has permission' do
      user.ability.should_receive(:authorize!).with(:destroy, discussion)
      DiscussionService.destroy(discussion: discussion, actor: user)
    end

    context 'actor is permitted' do
      it 'deletes the discussion' do
        discussion.should_receive :destroy
        DiscussionService.destroy(discussion: discussion, actor: user)
      end
    end

    context 'actor is not permitted' do
      it 'does not delete the discussion' do
        expect { DiscussionService.destroy discussion: discussion, actor: another_user }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
