class Groups::GroupSetupController < GroupBaseController

  before_filter :load_group
  before_filter :require_current_user_is_group_admin
  before_filter :redirect_to_group_if_already_setup

  def setup
  end

  def finish
    if @group.update_attributes(permitted_params.group)
      @group.mark_as_setup!
      @group.update default_group_cover: DefaultGroupCover.sample
      redirect_to @group
    else
      render 'setup'
    end
  end

  private

  def redirect_to_group_if_already_setup
    if @group.is_setup?
      flash[:warning] = t("error.group_already_setup")
      redirect_to @group
    end
  end
end
