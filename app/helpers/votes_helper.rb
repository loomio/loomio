module VotesHelper
  def vote_submit_button_text
    if action_name == 'new'
      t("vote_form.submit")
    else
      t("vote_form.update")
    end
  end
end
