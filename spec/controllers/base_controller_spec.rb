describe BaseController do
  context 'set_time_zone_if_blank' do
    it 'updates current_user.time_zone' do
      pending 'not sure this is worth the effort'
      params[:javascript_time_zone] = 'Pacific/Auckland'
      controller.send(:set_time_zone_if_blank)
    end
  end
end
