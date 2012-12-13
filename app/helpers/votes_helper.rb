module VotesHelper
  def get_button_label
    if action_name == 'new'
      return 'Submit position'
    else
      return 'Update position'
    end
  end
end