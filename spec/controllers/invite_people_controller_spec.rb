require 'spec_helper'

describe InvitePeopleController do
  let(:user){ create :user }

  before do
    sign_in user
  end


  describe 'POST create', focus: true do
    let(:group){ stub(:group) } 
    before do
      Group.stub(:find).and_return(group)
    end

    it 'ensures the user has the right to invite people to the group'

    context 'form is valid' do
      let(:invite_people){ stub(:invite_people, 
                                :valid? => true,
                                :parsed_recipients => ['jim@james.com'],
                                :message_body => 'yo, click this {invitation_link}') }

      let(:invitation) { stub(:invitation) }
      let(:invite_people_mailer) {stub(:invite_people_mailer, deliver: true)}

      it 'creates invitations to each recipient' do

        InvitePeople.should_receive(:new).and_return(invite_people)

        CreateInvitation.
          should_receive(:to_join_group).
          with(:recipient_email => 'jim@james.com',
               :group => group,
               :inviter => user).
          and_return(invitation)

        InvitePeopleMailer.
          should_receive(:to_join_group).
          with(invitation, invite_people.message_body).
          and_return(invite_people_mailer)

        post :create, id: 1, invite_people: {message_body: 'yo, click this {invitation_link}' }

        response.should redirect_to group_path(group)
      end
    end

    context 'form is invalid' do
      it 'renders the new template'
    end
  end

  describe 'GET new' do
    context 'for a group I am an admin of' do
      before do
        sign_in @user = FactoryGirl.create(:user)
        @group = create :group
        @group.add_admin!(@user)
      end

      it 'renders the invite people to join group form' do
        get :new, group_id: @group.id
        response.should be_success
      end
    end
  end

end
