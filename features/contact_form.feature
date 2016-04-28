Feature: Person contacts Loomio using contact form

@javascript
Scenario: Guest contacts Loomio using contact form
When I visit the contact page
And I fill in and submit the contact form
Then I should see a thank you flash message
And an email should be sent to @incoming.intercom.io
And the message should be saved to the database

Scenario: User contacts Loomio using contact form
Given I am a current user
When I visit the contact page
Then I should see my name and email pre-filled

Scenario: Guest tries to submit invalid contact form
When I visit the contact page
And I submit the contact form without filling in any fields
Then I should see the contact form with validation errors
