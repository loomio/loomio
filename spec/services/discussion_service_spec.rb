require 'rails_helper'

describe 'DiscussionService' do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:admin) { create(:user) }
  let(:group) { create(:group) }
  let(:another_group) { create(:group, is_visible_to_public: false) }
  let(:discussion) { create(:discussion, author: user, group: group) }
  let(:comment) { double(:comment,
                         save!: true,
                         valid?: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         destroy: true,
                         author: user) }
  let(:attachment) { create(:attachment) }
  let(:discussion_params) { {title: "new title", description: "new description", private: true, uses_markdown: true} }

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

    it 'clears out the draft' do
      draft = create(:draft, user: user, draftable: discussion.group, payload: { discussion: { name: 'name draft' } })
      DiscussionService.create(discussion: discussion, actor: user)
      expect(draft.reload.payload['discussion']).to be_blank
    end

    describe 'make_announcement' do
      it 'notifies users when make_announcement is true' do
        discussion.make_announcement = true
        expect { DiscussionService.create(discussion: discussion, actor: user) }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'does not notify userse when make_announcement is false' do
        discussion.make_announcement = false
        expect { DiscussionService.create(discussion: discussion, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
      end
    end

    context 'the discussion is valid' do
      before { discussion.stub(:valid?).and_return(true) }

      it 'syncs the discussion search vector' do
        SearchVector.should_receive(:index!).with(discussion.id)
        DiscussionService.create(discussion: discussion,
                                 actor: user)
      end

      it 'notifies new mentions' do
        discussion.group.add_member! another_user
        discussion.description = "A mention for @#{another_user.username}!"
        expect(Events::UserMentioned).to receive(:publish!).with(discussion, user, another_user)
        DiscussionService.create(discussion: discussion, actor: user)
      end

      it 'does not notify users outside the group' do
        discussion.description = "A mention for @#{another_user.username}!"
        expect(Events::UserMentioned).to_not receive(:publish!).with(discussion, user, another_user)
        DiscussionService.create(discussion: discussion, actor: user)
      end

      it 'marks the discussion reader as participating' do
        DiscussionService.create(discussion: discussion, actor: user)
        expect(DiscussionReader.for(user: user, discussion: discussion).participating).to eq true
      end

      it 'sets the volume to loud if the user has set email_on_participation' do
        user.update(email_on_participation: true)
        DiscussionService.create(discussion: discussion, actor: user)
        expect(DiscussionReader.for(user: user, discussion: discussion).volume).to eq 'loud'
      end

      it 'does not set the volume if the user has not set email_on_participation' do
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
      expect(Events::UserMentioned).to receive(:publish!).with(discussion, user, another_user)
      DiscussionService.update(discussion: discussion, params: discussion_params, actor: user)
    end

    it 'notifies new mentions with editor' do
      discussion.group.add_member! another_user
      discussion.group.add_admin! admin
      discussion_params[:description] = "A mention for @#{another_user.username}!"
      expect(Events::UserMentioned).to receive(:publish!).with(discussion, admin, another_user)
      DiscussionService.update(discussion: discussion, params: discussion_params, actor: admin)
    end

    it 'does not renotify old mentions' do
      discussion.group.add_member! another_user
      discussion_params[:description] = "A mention for @#{another_user.username}!"
      expect { DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to change { another_user.notifications.count }.by(1)
      discussion_params[:description] = "Hello again @#{another_user.username}"
      expect { DiscussionService.update(discussion: discussion, params: discussion_params, actor: user) }.to_not change  { another_user.notifications.count }
    end

    it 'does not notify users outside of the group' do
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
        SearchVector.should_receive(:index!).with(discussion.id)
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
      end

      it 'creates a version with updated title / description / private values' do
        DiscussionService.update discussion: discussion,
                                 params: discussion_params,
                                 actor: user
        version = PaperTrail::Version.last
        expect(version.object_changes['title'][1]).to eq discussion_params[:title]
        expect(version.object_changes['description'][1]).to eq discussion_params[:description]
      end

      it 'creates a version with updated attachment_ids' do
        expect { DiscussionService.update discussion: discussion,
                   params: { attachment_ids: [attachment.id] },
                   actor: user }.to change { discussion.versions.count }.by(1)
        version = PaperTrail::Version.last
        expect(version.object_changes['attachment_ids'][0]).to eq []
        expect(version.object_changes['attachment_ids'][1]).to eq [attachment.id]
      end

      it 'updates the existing version with attachment_ids' do
        discussion_params[:attachment_ids] = [attachment.id]
        expect { DiscussionService.update discussion: discussion,
                   params: discussion_params,
                   actor: user }.to change { discussion.versions.count }.by(1)
        version = PaperTrail::Version.last
        expect(version.object_changes['title'][1]).to eq discussion_params[:title]
        expect(version.object_changes['attachment_ids'][0]).to eq []
        expect(version.object_changes['attachment_ids'][1]).to eq [attachment.id]
      end

      it 'removes attachments in the version' do
        discussion.update(attachment_ids: [attachment.id])
        expect { DiscussionService.update discussion: discussion,
                   params: { attachment_ids: [] },
                   actor: user }.to change { discussion.versions.count }.by(1)
        version = PaperTrail::Version.last
        expect(version.object_changes['attachment_ids'][0]).to eq [attachment.id]
        expect(version.object_changes['attachment_ids'][1]).to eq []
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

  describe 'move' do
    it 'can move a discussion to another group the user is a member of' do
      group.users << user
      another_group.users << user
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.group).to eq another_group
    end

    it 'updates the privacy for private discussion only groups' do
      group.users << user
      another_group.users << user
      another_group.update_column :discussion_privacy_options, 'public_only'
      discussion.update private: true
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.private).to eq false
    end

    it 'updates the privacy for public discussion only groups' do
      group.users << user
      another_group.users << user
      another_group.update_column :discussion_privacy_options, 'private_only'
      discussion.update private: false
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.private).to eq true
    end

    it 'can move a discussion the user is author of' do
      group.admins << user
      another_group.users << user
      discussion.update author: another_user
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user)
      expect(discussion.reload.group).to eq another_group
    end

    it 'does not update other discussion attributes' do
      group.admins << user
      another_group.users << user
      DiscussionService.move(discussion: discussion, params: { group_id: another_group.id, title: 'teehee!' }, actor: user)
      expect(discussion.reload.title).not_to eq 'teehee!'
    end

    it 'does not move a discussion the user cannot move' do
      group.users << user
      another_group.users << user
      discussion.update author: another_user
      expect { DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user) }.to raise_error CanCan::AccessDenied
      expect(discussion.reload.group).to_not eq another_group.id
    end

    it 'does not move a discussion to a group the user is not a member of' do
      group.users << user
      expect { DiscussionService.move(discussion: discussion, params: { group_id: another_group.id }, actor: user) }.to raise_error CanCan::AccessDenied
      expect(discussion.reload.group).to_not eq another_group.id
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
