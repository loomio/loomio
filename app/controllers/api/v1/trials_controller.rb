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

    group = Group.new(
      name: params[:group_name].strip,
      description: MarkdownService.render_html(String(params[:group_intention]).strip + "\n\n" + String(params[:group_decisions]).strip),
      description_format: 'html',
      group_privacy: "secret",
      category: params[:group_category],
    )
    group.handle = GroupService.suggest_handle(name: group.name, parent_handle: nil)
    GroupService.create(group: group, actor: user, skip_authorize: true)

    raise "start trial failed" unless group.valid?
    
    group_path = group.handle ? group_handle_path(group.handle) : group_path(group)

    render json: {success: :ok, group_path: group_path}
  end
end
