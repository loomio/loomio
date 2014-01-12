class GroupsRedirectController < ApplicationController
  before_filter :load_resource_from_id

  def show
    redirect_to group_path(@group)
  end

  private

    def load_resource_from_id
      @group = Group.find(params[:id])
    end

end
