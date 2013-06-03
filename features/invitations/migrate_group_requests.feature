Feature: Group requests that are approved but not accepted are migrated to the new invitations system

  Scenario: Approved Group request gets invitation created
    Given there is an approved GroupRequest
    When I migrate Group Requests
    Then there should be an invitation to start that group

  Scenario: Visiting start group request link redirects to invitation path
    When I visit a GroupRequest#start new group 
    Then I should be redirected to invitations with the same token
