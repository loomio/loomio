Feature: Start new group
  In order to bring my group onto Loomio
  As a group coordinator
  I want to create a new group

@javascript
Scenario: Guest creates subscripton group
  Given I am a guest
  And I am on the home page of the website
  When I go to start a new group
  And I choose the subscription plan
  And I fill in and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I sign up as a new user
  And I setup the group
  Then I should see the group page without a contribute link

Scenario: User creates subscripton group
  Given I am logged in
  When I go to start a new group from the navbar
  And I choose the subscription plan
  When I fill in the group name and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I setup the group
  And the example content should be created
  Then I should see the group page without a contribute link

@javascript
Scenario: Logged out user creates subscripton group
  Given I am a logged out user
  And I am on the home page of the website
  When I go to start a new group
  And I choose the subscription plan
  And I fill in and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I sign in to Loomio
  And I setup the group
  Then I should see the group page without a contribute link

Scenario: Guest creates Pay What You Can group
  Given I am a guest
  And I am on the home page of the website
  When I go to start a new group
  And I choose the pay what you can plan
  And I fill in and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  # And show me the page
  And I sign up as a new user
  And I setup the group
  Then I should see the group page with a contribute link

Scenario: User existing user creates Pay What You Can group
  Given I am logged in
  When I go to start a new group from the navbar
  And I choose the pay what you can plan
  And I fill in the group name and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I setup the group
  Then I should see the group page with a contribute link

Scenario: Logged out user creates Pay What You Can group
  Given I am a logged out user
  And I am on the home page of the website
  When I go to start a new group
  And I choose the pay what you can plan
  And I fill in and submit the form
  Then I should see the thank you page
  And I should recieve an email with an invitation link
  When I click the invitation link
  And I sign in to Loomio
  And I setup the group
  Then I should see the group page with a contribute link
