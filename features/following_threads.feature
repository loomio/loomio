Feature: Following Threads

Background:
  Given Dr. Follow By Email likes to be emailed threads he is following
  And Dr. Follow By Email is following everything in this group
  And Mr. New Threads Only does like to be emailed about new discussions and proposals
  But Mr. New Threads Only does not like to be emailed threads he is following
  And Mrs. No Email Please does not like to be emailed about anything

Scenario: New discussion
  When I start a new discussion
  Then "Dr. Follow By Email" should be emailed
  And "Mr. New Threads Only" should be emailed
  And "Mrs. No Email Please" should not be emailed
  And I should not be emailed

Scenario: New comment
  When I add a comment
  Then "Dr. Follow By Email" should be emailed
  And "Mr. New Threads Only" should not be emailed
  And "Mrs. No Email Please" should not be emailed
  And I should not be emailed

Scenario: New mention
  When I mention Mr. New Threads Only
  Then "Dr. Follow By Email" should be emailed
  And "Mr. New Threads Only" should be emailed and notified
  And "Mrs. No Email Please" should not be emailed
  And I should not be emailed

Scenario: New proposal
  When I start a new proposal
  Then "Dr. Follow By Email" should be emailed
  And "Mr. New Threads Only" should be emailed
  And "Mrs. No Email Please" should not be emailed
  And I should not be emailed

Scenario: New vote
  When I vote on the proposal
  Then "Dr. Follow By Email" should be emailed
  And "Mr. New Threads Only" should not be emailed
  And "Mrs. No Email Please" should not be emailed
  And I should not be emailed

Scenario: Proposal closing soon
  When my proposal is about to close
  Then "Dr. Follow By Email" should be emailed and notifed
  And "Mr. New Threads Only" should be emailed and notifed
  And "Mrs. No Email Please" should be notified but not emailed
  And I should not be emailed or notified

Scenario: Proposal closed
  When my proposal closes
  Then I should be emailed and notifed
  And  "Dr. Follow By Email" should be emailed
  And "Mr. New Threads Only" should not be emailed
  And "Mrs. No Email Please" should not be emailed
