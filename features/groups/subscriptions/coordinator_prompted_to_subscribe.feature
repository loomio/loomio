#Feature: Coordinator prompted to subscribe
  #As a coordinator of a successful group
  #So that I can contribute to the ongoing development of Loomio
  #I want to know about the subscription model

  #Background:
    #Given I am logged in
    #And I am a coordinator of a group
    #And I have not selected a subscription plan

  #Scenario: Coordinator prompted to subscribe
    #Given the group is due for a subscription prompt
    #When I visit the group page
    #Then I should see the subscription prompt

  #Scenario: Coordinator not prompted to subscribe
    #Given the group is not due for a subscription prompt
    #When I visit the group page
    #Then I should not see the subscription prompt

