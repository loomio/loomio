Feature: Create sub group
	
	Background:
		Given a group "demo-group" with "abc@loomio.com" as admin
		And I am logged in as "abc@loomio.com"
		And I visit create subgroup page for group named "demo-group"

	Scenario: Create public subgroup with all group members invite
		When I fill details for  public all members invite subgroup
		And I click "Create group"
		Then I should see "Group created successfully"

	Scenario: Create public subgroup with only admin invite
		When I fill details for public admin only invite subgroup
		And I click "Create group"
		Then I should see "Group created successfully"

	Scenario: Create members only subgroup with all group members invite
		When I fill details for members only all members invite subgroup
		And I click "Create group"
		Then I should see "Group created successfully"

	Scenario: Create members only subgroup with only admin invite
		When I fill details for members only admin invite subgroup
		And I click "Create group"
		Then I should see "Group created successfully"


	Scenario: Create members and parent members only subgroup with all group members invite
		When I fill details for members and parent members only all members invite subgroup
		And I click "Create group"
		Then I should see "Group created successfully"


	Scenario: Create members and parent members only subgroup with only admin invite
		When I fill details for members and parent members admin only invite ubgroup
		And I click "Create group"
		Then I should see "Group created successfully"