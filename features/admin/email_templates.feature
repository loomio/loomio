Feature: Email Templates

  Background:
    Given I am a logged in system admin

  Scenario: System admin creates email template
    When I visit the admin email templates page
    And I click "New Email Template"
    And fill in and submit the email template form
    Then I should see the email template was created

  Scenario: System admin previews email template
    Given there is an email template
    When I visit the email templates page
    And I click to preview the email template
    Then I should see how the email template will look when sent

  @javascript
  Scenario: System admin uses template to generate emails to group members
    Given there is an email template
    And a group exists
    When I visit the admin groups page and click email
    And I choose my template and the group contact person
    Then a pending email to the group contact person, based on the template, should be created
    And a record that the group had the email templated should exist

  @javascript
  Scenario: System admin is notified if they try to resent a template to a group
    Given I've sent an email template to a group already
    When I try to send the same email template to the same group
    Then I should be told that I've already sent that email template to that group

  Scenario: System admin previews outbound email
    Given an email has been generated from a template
    When I visit the outbound emails page
    And I click to preview the email
    Then I should see what the email will look like to the user

  @javascript
  Scenario: System admin sends outbound email
    Given an email has been generated from a template
    When I visit the outbound emails page
    And I send the email
    Then the email should be sent to the recipient
