class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    @admin_group_ids = user.adminable_group_ids
    @member_group_ids = user.group_ids

    cannot :sign_up, User

    can :show, Group do |group|
      if group.archived?
        false
      else
        case group.privacy.to_s
        when 'public'
          true
        when 'private'
          true
        when 'secret'
          if group.viewable_by_parent_members?
            @member_group_ids.include?(group.id) or @member_group_ids.include?(group.parent_id)
          else
            @member_group_ids.include?(group.id)
          end
        end
      end
    end

    # TODO: Refactor to use subscription resource
    can [:view_payment_details,
         :choose_subscription_plan], Group do |group|
      group.is_top_level? and @admin_group_ids.include?(group.id) and !group.has_manual_subscription?
    end

    can [:update,
         :email_members,
         :hide_next_steps,
         :archive], Group do |group|
      @admin_group_ids.include?(group.id)
    end

    can [:add_subgroup,
        :edit_description,
        :members_autocomplete], Group do |group|
      @member_group_ids.include?(group.id)
    end

    can [:add_members,
         :manage_membership_requests], Group do |group|
      case group.members_invitable_by
      when 'members'
        @member_group_ids.include?(group.id)
      when 'admins'
        @admin_group_ids.include?(group.id)
      end
    end

    can :invite_people, Group do |group|
      if group.is_a_subgroup?
        false
      else
        case group.members_invitable_by
        when 'members'
          @member_group_ids.include?(group.id)
        when 'admins'
          @admin_group_ids.include?(group.id)
        end
      end
    end

    can :create, Group do |group|
      if group.parent_id.present?
        @member_group_ids.include?(group.parent_id)
      else
        false
      end
    end

    can [:make_admin], Membership do |membership|
      @admin_group_ids.include?(membership.group_id)
    end

    can [:remove_admin,
         :destroy], Membership do |membership|
      if membership.group.members.size == 1
        false
      elsif membership.admin? and membership.group.admins.size == 1
        false
      else
        (membership.user == user) or @admin_group_ids.include?(membership.group_id)
      end
    end

    can :deactivate, User do |user_to_deactivate|
      not user_to_deactivate.adminable_groups.any? { |g| g.admins.count == 1 }
    end

    can :request_membership, Group do |group|
      if group.is_sub_group?
        group.parent.members.include?(user) and can?(:show, group)
      else
        can?(:show, group)
      end
    end

    can :cancel, MembershipRequest, requestor_id: user.id

    can [:approve,
         :ignore], MembershipRequest do |membership_request|
      group = membership_request.group

      group.admins.include?(user) or
        (group.members_can_invite_members? and
         group.members.include?(user))
    end

    can :show, Discussion do |discussion|
      group = discussion.group
      if group.privacy == 'public' || group.members.include?(user)
        can? :show, group
      else
        false
      end
    end

    can [:destroy,
         :move], Discussion do |discussion|
      @admin_group_ids.include?(discussion.group_id)
    end

    can [:unfollow,
         :add_comment,
         :new_proposal,
         :create,
         :update_description,
         :edit_title,
         :show_description_history,
         :preview_version,
         :like_comments,
         :update_version], Discussion do |discussion|
      @member_group_ids.include?(discussion.group_id)
    end

    can [:destroy], Comment do |comment|
      (comment.author == user) or @admin_group_ids.include?(comment.group.id)
    end

    can [:create, :vote], Motion do |motion|
      motion.voting? && @member_group_ids.include?(motion.group.id)
    end

    can [:destroy,
         :close,
         :create_outcome,
         :update_outcome,
         :edit_close_date], Motion do |motion|
      (motion.author == user) or @admin_group_ids.include?(motion.group.id)
    end
  end
end

