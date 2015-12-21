Feature: Subscribe to feed
  As a visitor to a public group
  To more easily keep up with group updates
  I should be able to subscribe to a feed of discussions within the group

  Scenario: Subscribe to feed link is present for public group
    Given I am logged in
  	And there is a discussion in a public group
    And I visit the group page
    Then I should see a subscribe to feed link

  Scenario: Subscribe to feed link is not present for private group
    Given I am logged in
  	Given there is a discussion in a private group
  	And I visit the group page
  	Then I should not see a subscribe to feed link

  Scenario: Clicking the Subscribe to feed link returns an xml feed
    Given I am logged in
  	Given there is a discussion in a public group
  	And I visit the group page
  	And I visit the subscribe to feed link
  	Then I should see an xml feed
