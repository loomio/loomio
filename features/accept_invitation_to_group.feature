Feature: User accepts invitation to Loomio group
  As a future Loomio user
  So that I can make decisions with my group on Loomio
  I want to be able to accept an invitation to Loomio

  Scenario: Logged-out user visits invite link
    Given I have been invited to join a loomio group and I am a new user
    When I open the email and click the invitation link
    Then I should see a page that explains that my group is using Loomio to make decisions
    And I should be asked to create an account or log-in

  Scenario: New user accepts invite to Loomio group
    Given I have been invited to join a loomio group and I am a new user
    When I open the email and click the invitation link
    And I create my user account
    Then I should become a member of the group
    And I should be taken to the group's demo proposal page

  Scenario: Existing logged-out user accepts invite to Loomio group
    Given I have been invited to join a loomio group and I am an existing user
    When I open the email and click the invitation link
    And I log in
    Then I should become a member of the group
    And I should be taken to the group page

  Scenario: Existing logged-in user accepts invite to Loomio group
    Given I have been invited to join a loomio group and I am an existing user
    And I am logged in
    When I open the email and click the invitation link
    Then I should become a member of the group
    And I should be taken to the group page

  Scenario: User being the first to accept the invite becomes the group admin
    Given I have requested to start a loomio group and the requst has been approved
    When I open the email and click the invitation link
    And I log in
    Then I should become the admin of the group

  Scenario: User tries to create an account without an invitation
    Given I have not received an invitation
    When I visit the create account page
    Then I should be redirected to the homepage

  Scenario: User tries to accept a used invitation
    Given there is an accepted invitation
    When I visit the invitation link
    Then I should see a message that the invitation has already been used
    And I should not become a member of the group

