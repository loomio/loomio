Feature: Create Proposal
  In order to make the site a productive place
  Users must be able to create proposals

  Background:
    Given a group "demo-group" with "furry@example.com" as admin
    And I am logged in as "furry@example.com"

  # TODO - This needs to be changed to work from the discussions page
  #Scenario: Create Proposal as Group User
    #Given a group is created
    #When I am on a group page
    #And I click create proposal
    #And fill in the proposal details
    #Then a new proposal is created
