GroupWithCreator = Struct.new(:params) do

  def group
    @group ||= Group.new(group_params)
  end

  def errors
    return [] if new?
    [
      ('group_name' unless group.valid?),
      ('email'      unless params[:email].present?),
      ('name'       unless params[:name].present?)
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
