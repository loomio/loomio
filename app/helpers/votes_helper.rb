module VotesHelper
  def vote_submit_button_text
    if action_name == 'new'
      return 'Submit position'
    else
      return 'Update position'
    end
  end

  def vote_icon_name(position)
    if position
      icon_name = 'position-yes-icon' if position == "yes"
      icon_name = 'position-abstain-icon' if position == "abstain"
      icon_name = 'position-no-icon' if position == "no"
      icon_name = 'position-block-icon' if position == "block"
    else
      icon_name = "position-unvoted-icon"
    end
    icon_name
  end
end