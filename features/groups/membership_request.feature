Feature: Request Membership to Group
  As a signed in OR signed out individual
  So that I can participate in discussions I'm interested in
  I want to be able to join groups

  Scenario: User cannot join invitation only group
    Given I am logged in
    And a visible but invitation only group exists
    When I visit the group page
    Then I should see that membership is by invitation only

  Scenario: Member of parent cannot join invitation only subgroup
    Given I am logged in
    And I am a member of a group with an invitation only subgroup that is visible to parent members
    When I visit the subgroup page
    Then I should see that I need an invitation to join

  Scenario: Vistor requests membership to approval required group
    Given I am a visitor
    And an approval required group exists
    When I visit the group page
    And I click "Ask to join group"
    And I fill in and submit the Request membership form
    Then I should see a flash message confirming my membership request

  Scenario: User requests membership to approval required group
    Given I am logged in
    And an approval required group exists
    When I visit the group page
    And I click "Ask to join group"
    And I fill in and submit the Request membership form (introduction only)
    Then I should see a flash message confirming my membership request

  Scenario: Visitor cannot request membership to a group using email of existing member
    Given I am a visitor
    When I visit the request membership page for a group
    And I fill in and submit the Request membership form using email of existing member
    Then I should see a field error telling me I am already a member of the group

  Scenario: Visitor requests membership, is ignored, then requests again
    Given I am a visitor
    And I have requested membership as a visitor and been ignored
    When I visit the group page
    And I click "Ask to join group"
    And I fill in and submit the Request membership form
    Then I should see a flash message confirming my membership request

  Scenario: User with pending membership request cannot submit new request
    Given I am logged in
    And I have requested membership to a group
    When I visit the request membership page for the group
    And I fill in and submit the Request membership form (introduction only)
    Then I should see a flash message telling me I have already requested membership
    And I should be redirected to the group page

  Scenario: User requests membership, is approved, leaves the group, and then requests again
    Given I am logged in
    And I have requested membership, been accepted to, and then left a group
    When I visit the group page
    And I click "Ask to join group"
    And I fill in and submit the Request membership form (introduction only)
    Then I should see a flash message confirming my membership request

  Scenario: User requests membership, is ignored, then requests again
    Given I am logged in
    And I have requested membership and been ignored
    When I visit the group page
    And I click "Ask to join group"
    And I fill in and submit the Request membership form (introduction only)
    Then I should see a flash message confirming my membership request

  Scenario: Member of a group cannot request membership to their own group
    Given I am logged in
    And I am a member of a group
    When I visit the request membership page for the group
    And I fill in and submit the Request membership form (introduction only)
    And I should see a flash message telling me I am already a member of the group


## Cancel Membership Request

  Scenario: User cancels their membership request
    Given I am logged in
    And I have requested membership to a group
    When I visit the group page
    And I click "Cancel request"
    Then I should no longer see the Membership requested button
    And I should see the request membership button

## Approve Membership Request

  # @javascript
  Scenario: A member with permission approves membership request from visitor
    Given I am a logged in coordinator of a group
    And there is a membership request from a signed-out user
    When I approve the membership request
    Then I should see a flash message confirming the membership request was approved
    And I should no longer see the membership request in the list
    And the requester should be sent an invitation to join the group

  Scenario: A member with permission approves membership request from user
    Given I am a logged in coordinator of a group
    And there is a membership request from a user
    When I approve the membership request
    Then I should see a flash message confirming the membership request was approved
    And I should no longer see the membership request in the list
    And the requester should be added to the group
    And the requester should be emailed of the approval

  Scenario: An unauthorized member cannot visit the membership requests page of the group
    Given I am logged in
    And I am a member of a group
    And membership requests can only be managed by group admins for the group
    And there is a membership request from a user
    When I try to visit the membership requests page for the group
    Then I should be returned to the group page


  ## Ignore Membership Request

  Scenario: A member with permission ignores a membership request
    Given I am a logged in coordinator of a group
    And there is a membership request from a user
    When I ignore the membership request
    Then I should see a flash message confirming the membership request was ignored
    And I should no longer see the membership request in the list
