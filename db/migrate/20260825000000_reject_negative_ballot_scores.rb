class RejectNegativeBallotScores < ActiveRecord::Migration[8.1]
  def up
    # NOT VALID enforces the invariant for new writes without revisiting
    # negative scores stored by older Loomio versions.
    add_check_constraint :stance_choices,
                         "score >= 0",
                         name: "stance_choices_score_nonnegative",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :anonymous_ballot_choices,
                         "score >= 0",
                         name: "anonymous_ballot_choices_score_nonnegative",
                         validate: false,
                         if_not_exists: true
  end

  def down
    remove_check_constraint :anonymous_ballot_choices,
                            name: "anonymous_ballot_choices_score_nonnegative",
                            if_exists: true
    remove_check_constraint :stance_choices,
                            name: "stance_choices_score_nonnegative",
                            if_exists: true
  end
end
