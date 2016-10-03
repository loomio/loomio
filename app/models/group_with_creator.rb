GroupWithCreator = Struct.new(:params) do

  def start!
    return unless errors.empty?
    GroupService.delay.create(group: group, actor: LoggedOutUser.new)
    InvitationService.delay.invite_admin_to_group(group: group, name: name, email: email)
  end

  def group
    @group ||= Group.new(group_params)
  end

  def email
    @email ||= params[:email]
  end

  def name
    @name  ||= params[:name]
  end

  def errors
    return [] if new?
    [
      ('group_name' unless group.valid?),
      ('email'      unless email.present?),
      ('name'       unless name.present?)
    ].compact
  end

  private

  def new?
    params[:action] == 'new'
  end

  def group_params
    return {} if new?
    { name: params.dig(:group, :name), description: params.dig(:group, :description) }
  end

end
