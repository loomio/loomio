module Ability
  class Base
    include CanCan::Ability
    prepend Ability::Comment
    prepend Ability::ContactRequest
    prepend Ability::DiscussionReader
    prepend Ability::Discussion
    prepend Ability::Document
    prepend Ability::Group
    prepend Ability::Identity
    prepend Ability::MembershipRequest
    prepend Ability::Membership
    prepend Ability::Outcome
    prepend Ability::Poll
    prepend Ability::Reaction
    prepend Ability::Stance
    prepend Ability::User
    prepend Ability::Tag
    prepend Ability::DiscussionTag
    prepend Ability::Event
    prepend Ability::Webhook
    prepend Ability::Attachment


    def initialize(user)
      @user = user
      can(:subscribe_to, GlobalMessageChannel) { true }
    end

    private

    def user_is_member_of?(group_id)
      @user.memberships.find_by(group_id: group_id)
    end

    def user_is_admin_of?(group_id)
      @user.admin_memberships.find_by(group_id: group_id)
    end

    def user_is_member_of_any?(groups)
      @user.memberships.find_by(group: groups)
    end

    def user_is_admin_of_any?(groups)
      @user.admin_memberships.find_by(group: groups)
    end

    def user_is_author_of?(object)
      @user.is_logged_in? && @user.id == object.author_id
    end

  end
end
