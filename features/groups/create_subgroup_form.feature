Feature: Create a subgroup form

Scenario: Create subgroup of hidden group
  Given there is a hidden parent group
  When I load the create subgroup form
  Then the 'finding the group' options should metion the parent
  And the 'joining the group' options should mention the parent
  And the 'discussion privacy' options should mention the parent

Scenario: Create subgroup of hidden group
  Given there is a hidden parent group
  When I load the create subgroup form
  Then all the joining options should be available
  And 'who can add members?' should show
  And both discussion privacy options should be available
  When I select 'only members can see the group'
  Then 'invitation only' should be exclusively selected
  And 'who can add members?' should show
  And 'only members can see discussions' should be selected
  And 'anyone in parent can see discussions' should be disabled

Scenario: Create subgroup of visible group
  Given there is a visible parent group
  And I have loaded the create subgroup form

  When a group is made visible, join on request
  Then discussion privacy is set to public, and other options are disabled

  When a group is made visible, join on approval
  Then 'who can add members?' should show
  And all 3 discussion privacy options are available

  When a group is made hidden
  Then the form selects invitation only, and disables other join options
  And 'who can add members?' should show
  And private discussions only is selected, other privacy options disabled

