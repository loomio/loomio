class Ability
  include CanCan::Ability

  def initialize(user, params)
    can :create, Membership
    can :edit, Membership
    can :update, Membership do |membership|
      if params[:membership]
        if params[:membership][:access_level] == 'member'
          membership.can_be_made_member_by? user
        elsif params[:membership][:access_level] == 'admin'
          membership.can_be_made_admin_by? user
        end
      end
    end

    can :destroy, Membership do |membership|
      membership.can_be_deleted_by? user
    end
  end
end
