Feature: Following by email

Background:
  Given I am the logged in admin of a group
  And Dr Follow By Email wants to be emailed new threads and activity he is following
  And Dr Follow By Email is following everything in this group
  And Mr New Threads Only only wants to be emailed about new discussions and proposals
  And Ms Prop Close Soon only wants to know about proposals that are about to close
  And Mrs No Email Please does not want to be emailed about anything

Scenario: New discussion
  When I start a new discussion
  Then "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should be emailed
  And "Mrs No Email Please" should not be emailed
  And "Ms Prop Close Soon" should not be emailed
  And I should not be emailed

Scenario: New comment
  When I add a comment
  Then "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should not be emailed
  And "Mrs No Email Please" should not be emailed
  And "Ms Prop Close Soon" should not be emailed
  And I should not be emailed

Scenario: New mention
  When I mention Mr New Threads Only
  Then "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should be notified but not emailed about the new mention
  And "Mrs No Email Please" should not be emailed
  And "Ms Prop Close Soon" should not be emailed
  And I should not be emailed

Scenario: New proposal
  When I start a new proposal
  Then "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should be emailed
  And "Mrs No Email Please" should not be emailed
  And "Ms Prop Close Soon" should not be emailed
  And I should not be emailed

Scenario: New vote
  When I vote on the proposal
  Then "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should not be emailed
  And "Mrs No Email Please" should not be emailed
  And "Ms Prop Close Soon" should not be emailed
  And I should not be emailed

Scenario: Proposal closing soon
  When my proposal is about to close
  Then "Dr Follow By Email" should be emailed and notified about the proposal closing soon
  And "Mr New Threads Only" should be notified but not emailed about the proposal closing soon
  And "Mrs No Email Please" should be notified but not emailed about the proposal closing soon
  And "Ms Prop Close Soon" should be emailed
  And I should be emailed and notified about the proposal closing soon

Scenario: Proposal closed
  When my proposal closes
  Then I should be emailed and notified that the proposal closed
  And "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should not be emailed
  And "Mrs No Email Please" should not be emailed
  And "Ms Prop Close Soon" should not be emailed

Scenario: Proposal Outcome
  When I set a proposal outcome
  Then "Dr Follow By Email" should be emailed
  And "Mr New Threads Only" should be emailed
  And "Mrs No Email Please" should not be emailed
  # should proposal closing soon get an email?
  And "Ms Prop Close Soon" should not be emailed
