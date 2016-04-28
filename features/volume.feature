Feature: Volume

Background:
  Given I am logged in
  And I am an admin of a group
  And Loud Larry is following everything in the group by email
  And Normal Norman gets important events emailed as they happen
  And Quiet Quincey want to catch up by digest email
  And Mute megan mutes everything.
  And Hermit Harry turns off all emails.
  And Closing Soonsan mutes everything but wants to hear when proposals are closing and when mentioned.

Scenario: New discussion
  When I start a new discussion
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan" should not be emailed

Scenario: New comment
  When I add a comment
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should not be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan" should not be emailed

Scenario: New proposal
  When I start a new proposal
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan"      should not be emailed

Scenario: New vote
  When I vote on the proposal
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should not be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan"      should not be emailed

Scenario: Proposal closing soon
  When my proposal is about to close
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan"      should not be emailed
  And  "Closing Soonsan" should be emailed

Scenario: Proposal closed
  When my proposal closes
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should not be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan"      should not be emailed

Scenario: Proposal Outcome
  When I set a proposal outcome
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan"      should not be emailed

Scenario: New mention
  When I mention Mute Megan
  Then "Loud Larry"      should be emailed
  And  "Normal Norman"   should not be emailed
  And  "Quiet Quincey"   should not be emailed
  And  "Mute Megan"      should be emailed

Scenario: New mention for Hermit Harry
  When I mention Hermit Harry
  Then "Hermit Harry" should not be emailed
