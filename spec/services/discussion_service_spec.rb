require 'rails_helper'

describe 'DiscussionService' do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:admin) { create(:user) }
  let(:group) { create(:formal_group) }
  let(:another_group) { create(:formal_group, is_visible_to_public: false) }
  let(:discussion) { create(:discussion, author: user, group: group) }
  let(:poll) { create(:poll, discussion: discussion, group: group) }
  let(:comment) { double(:comment,
                         save!: true,
                         valid?: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         destroy: true,
                         author: user) }
  let(:document) { create(:document) }
  let(:discussion_params) { {title: "new title", description: "new description", private: true} }

  describe 'create' do
    it 'authorizes the user can create the discussion' do
      user.ability.should_receive(:authorize!).with(:create, discussion)
      DiscussionService.create(discussion: discussion,
                               actor: user)
    end

    it 'clears out the draft' do
      draft = create(:draft, user: user, draftable: discussion.group, payload: { discussion: { name: 'name draft' } })
      DiscussionService.create(discussion: discussion, actor: user)
      expect(draft.reload.payload['discussion']).to be_blank
    end

    it 'does not email people' do
      expect { DiscussionService.create(discussion: discussion, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
    end

    context 'the discussion is valid' do
      before { discussion.stub(:valid?).and_return(true) }

      it 'syncs the discussion search vector' do
        expect {DiscussionService.create(discussion: discussion, actor: user) }.to change {SearchVector.where(discussion_id: discussion.id).count}.by(1)
      end

      it 'notifies new mentions' do
        discussion.group.add_member! another_user
        discussion.description = "A mention for @#{another_user.username}!"
        expect { DiscussionService.create(discussion: discussion, actor: user) }.to change {
          Events::UserMentioned.where(kind: :user_mentioned).count
        }.by(1)
      end

      it 'does not notify users outside the group' do
        discussion.description = "A mention for @#{another_user.username}!"
        expect(Events::UserMentioned).to_not receive(:publish!).with(discussion, user, another_user)
        DiscussionService.create(discussion: discussion, actor: user)
      end

      it 'sets the volume to loud if the user has set email_on_participation' do
        user.update_attribute(:email_on_participation, true)
        DiscussionService.create(discussion: discussion, actor: user)
        expect(DiscussionReader.for(user: user, discussion: discussion).volume).to eq 'loud'
      end

      it 'does not set the volume if the user has not set email_on_participation' do
        user.update_attribute(:email_on_participation, false)
        DiscussionService.create(discussion: discussion, actor: user)
        expect(DiscussionReader.for(user: user, discussion: discussion).volume).to_not eq 'loud'
      end

      it 'fires a NewDiscussion event' do
        Events::NewDiscussion.should_receive(:publish!).with(discussion).and_return(true)
        DiscussionService.create(discussion: discussion,
                                 actor: user)
      end

      it 'returns the event created' do
        expect(DiscussionService.create(discussion: discussion,
                                 actor: user)).to be_a Event
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

    it 'notifies new mentions' do
      discussion.group.add_member! another_user
      discussion_params[:description] = "A mention for @#{another_user.username}!"
      expect { DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to change { another_user.notifications.count }.by(1)
      expect(another_user.notifications.last.kind).to eq 'user_mentioned'
    end

    it 'notifies new mentions with edit' do
      discussion.group.add_member! another_user
      discussion.group.add_admin! admin
      discussion_params[:description] = "A mention for @#{another_user.username}!"
      expect { DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to change { another_user.notifications.count }.by(1)
      expect(another_user.notifications.last.kind).to eq 'user_mentioned'
    end

    it 'does not renotify old mentions' do
      discussion.group.add_member! another_user
      discussion_params[:description] = "A mention for @#{another_user.username}!"
      expect { DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to change { another_user.notifications.count }.by(1)
      discussion_params[:description] = "Hello again @#{another_user.username}"
      expect { DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to_not change  { another_user.notifications.count }
    end

    it 'notifies users outside of the group' do
      discussion_params[:description] = "A mention for @#{another_user.username}!"
      expect(Events::UserMentioned).to_not receive(:publish!).with(discussion, user, another_user)
      DiscussionService.update(discussion: discussion, params: discussion_params, actor: user)
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
        DiscussionService.update(discussion: discussion, params: discussion_params, actor: user)
        discussion_params[:description] = "merry christmas everyone"
        expect {DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to change {SearchVector.where(discussion_id: discussion.id).first.search_vector}
      end

      it 'creates a version with updated title / description / private values' do
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
        version = PaperTrail::Version.last
        expect(version.object_changes['title'][1]).to eq discussion_params[:title]
        expect(version.object_changes['description'][1]).to eq discussion_params[:description]
      end

      it 'creates a version with updated document_ids' do
        expect { DiscussionService.update discussion: discussion,
                   params: { document_ids: [document.id] },
                   actor: user }.to change { discussion.versions.count }.by(1)
        version = PaperTrail::Version.last
        expect(version.object_changes['document_ids'][0]).to eq []
        expect(version.object_changes['document_ids'][1]).to eq [document.id]
      end

      it 'updates the existing version with document_ids' do
        discussion_params[:document_ids] = [document.id]
        expect { DiscussionService.update discussion: discussion,
                   params: discussion_params,
                   actor: user }.to change { discussion.versions.count }.by(1)
        version = PaperTrail::Version.last
        expect(version.object_changes['title'][1]).to eq discussion_params[:title]
        expect(version.object_changes['document_ids'][0]).to eq []
        expect(version.object_changes['document_ids'][1]).to eq [document.id]
      end

      it 'removes documents in the version' do
        discussion.update(document_ids: [document.id])
        expect { DiscussionService.update discussion: discussion,
                   params: { document_ids: [] },
                   actor: user }.to change { discussion.versions.count }.by(1)
        version = PaperTrail::Version.last
        expect(version.object_changes['document_ids'][0]).to eq [document.id]
        expect(version.object_changes['document_ids'][1]).to eq []
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
                                        params: { volume: :mute },
                                        actor: user
        expect(DiscussionReader.for(user: user, discussion: discussion).volume).to eq "mute"
      end
    end

    it 'does not update if the user cannot update the reader' do
      another_discussion = create(:discussion)
      expect { DiscussionService.update_reader discussion: another_discussion, params: { volume: :mute }, actor: user }.to raise_error CanCan::AccessDenied
      expect(DiscussionReader.for(user: user, discussion: another_discussion).volume).to_not eq "mute"
    end
  end

  describe 'move' do
    it 'can move a discussion to another group the user is a member of' do
      group.add_member! user
      another_group.add_member! user
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.group).to eq another_group
    end

    it 'updates the privacy for private discussion only groups' do
      group.add_member! user
      another_group.add_member! user
      another_group.update_column :discussion_privacy_options, 'public_only'
      discussion.update private: true
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.private).to eq false
    end

    it 'updates the privacy for public discussion only groups' do
      group.add_member! user
      another_group.add_member! user
      another_group.update_column :discussion_privacy_options, 'private_only'
      discussion.update private: false
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.private).to eq true
    end

    it 'can move a discussion the user is author of' do
      group.add_member! user
      another_group.add_member! user
      discussion.update author: user
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.group).to eq another_group
    end

    it 'does not update other discussion attributes' do
      group.add_member! user
      another_group.add_member! user
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id, title: 'teehee!' }, actor: user)
      expect(discussion.reload.title).not_to eq 'teehee!'
    end

    it 'does not move a discussion the user cannot move' do
      group.add_member! user
      another_group.add_member! user
      discussion.update author: another_user
      expect { DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user) }.to raise_error CanCan::AccessDenied
      expect(discussion.reload.group).to_not eq another_group.id
    end

    it 'does not move a discussion to a group the user is not a member of' do
      group.add_member! user
      expect { DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user) }.to raise_error CanCan::AccessDenied
      expect(discussion.reload.group).to_not eq another_group.id
    end

    it 'updates the group for any polls in the discussion' do
      group.add_member! user
      another_group.add_member! user
      poll
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.polls.first.group).to eq another_group
    end
  end

  describe 'destroy' do

    it 'checks the actor has permission' do
      user.ability.should_receive(:authorize!).with(:destroy, discussion)
      DiscussionService.destroy(discussion: discussion, actor: user)
    end

    context 'actor is permitted' do
      it 'deletes the discussion' do
        DiscussionService.destroy(discussion: discussion, actor: user)
        expect(discussion.discarded_at).to_not eq nil
      end
    end

    context 'actor is not permitted' do
      it 'does not delete the discussion' do
        expect { DiscussionService.destroy discussion: discussion, actor: another_user }.to raise_error CanCan::AccessDenied
      end
    end
  end
end
