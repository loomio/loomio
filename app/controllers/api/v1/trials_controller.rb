class API::V1::TrialsController < API::V1::RestfulController
  def create
    email = params[:user_email].strip

    user = User.verified.find_by(email: email)
    if !user
      user = User.where(email_verified: false, email: email).first_or_create
      user.name = params[:user_name].strip
      user.recaptcha = params[:recaptcha]
      user.legal_accepted = true
      user.email_newsletter = !!params[:newsletter]
      # user.require_valid_signup = true
      # user.require_recaptcha = true
      user.save!
    end

    raise "you said I'd have a user by now" unless user && user.valid?

    group = Group.new
    group.assign_attributes_and_files(params.require(:group).permit(permitted_params.group_attributes))
    group.group_privacy = "secret"
    group.category = params[:group_category]
    group.info['how_did_you_hear_about_loomio'] = params[:how_did_you_hear_about_loomio]

    group.handle = GroupService.suggest_handle(name: group.name, parent_handle: nil)
    GroupService.create(group: group, actor: user, skip_authorize: true)

    raise "start trial failed" unless group.valid?
    
    group_path = group.handle ? group_handle_path(group.handle) : group_path(group)

    render json: {success: :ok, group_path: group_path}
  end
end
