GroupWithCreator = Struct.new(:params) do

  def group
    @group ||= Group.new(group_params)
  end

  def creator
    @creator ||= LoggedOutUser.new(name: params[:name], email: params[:email])
  end

  def errors
    return [] if params[:action] == 'new'
    @errors ||= [
      ('group_name' unless group.valid?),
      ('email'      unless creator.email.present?),
      ('name'       unless creator.name.present?)
    ].compact
  end

  private

  def group_params
    params[:group].permit(:name, :description) if params[:group]
  end

end
