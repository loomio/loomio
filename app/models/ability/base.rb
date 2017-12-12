module Ability
  class Base
    include CanCan::Ability
    prepend Ability::Comment
    prepend Ability::ContactRequest
    prepend Ability::DiscussionReader
    prepend Ability::Discussion
    prepend Ability::Document
    prepend Ability::Draft
    prepend Ability::GroupIdentity
    prepend Ability::Group
    prepend Ability::Identity
    prepend Ability::Invitation
    prepend Ability::MembershipRequest
    prepend Ability::Membership
    prepend Ability::OauthApplication
    prepend Ability::Outcome
    prepend Ability::Poll
    prepend Ability::Reaction
    prepend Ability::Stance
    prepend Ability::User

    def initialize(user)
      @user = user
      can(:subscribe_to, GlobalMessageChannel) { true }
    end

    private

    def user_is_member_of?(group_id)
      @user.group_ids.include?(group_id)
    end

    def user_is_admin_of?(group_id)
      @user.adminable_group_ids.include?(group_id)
    end

    def user_is_author_of?(object)
      @user.is_logged_in? && @user.id == object.author_id
    end

  end
end
