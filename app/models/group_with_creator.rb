GroupWithCreator = Struct.new(:params) do

  def group
    @group ||= Group.new(group_params)
  end

  def creator
    { creator: params.slice(:name, :email) }
  end

  def errors
    return [] if params[:action] == 'new'
    [
      ('group_name' unless group.valid?),
      ('email'      unless params[:email].present?),
      ('name'       unless params[:name].present?)
    ].compact
  end

  private

  def group_params
    { name: params.dig(:group, :name), description: params.dig(:group, :description) }
  end

end
