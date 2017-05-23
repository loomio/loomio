Feature: Person contacts Loomio using contact form

Scenario: User contacts Loomio using contact form
Given I sign in
When I visit the contact page
Then I should see my name and email pre-filled

Scenario: Guest tries to submit invalid contact form
When I visit the contact page
And I submit the contact form without filling in any fields
Then I should see the contact form with validation errors
