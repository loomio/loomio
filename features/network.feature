Feature: Network of groups

Scenario: Request to join network
  Given I am ready to join network
  When I visit the request to join network page
  And fill in and submit the form
  Then there should be a pending network membership request for my group

Scenario: Approve request to join network
  Given there is a pending request to join the network
  When I visit the network membership requests page
  And I approve the pending request to join the network
  Then the group should be added to the network

Scenario: Decline request to join network
  Given there is a pending request to join the network
  When I visit the network membership requests page
  And I decline the pending request to join the network
  Then the group should not be added to the network