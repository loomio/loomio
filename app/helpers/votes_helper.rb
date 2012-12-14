module VotesHelper
  def vote_submit_button_text
    if action_name == 'new'
      return 'Submit position'
    else
      return 'Update position'
    end
  end
end