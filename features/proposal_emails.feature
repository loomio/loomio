Feature: Proposal emails

Scenario: Being emailed about proposals in an ongoing thread
  Given I have set my preferences to email me activity I'm following
  And I have set my preferences to email me about proposals
  When there is a new proposal in a group
  Then I should get the new proposal email

Scenario: Being emailed about proposals in a new thread
  Given I have set my preferences to not email me activity I'm following
  And I have set my preferences to email me about proposals
  When there is a new proposal in a group
  Then I should get the new proposal email

