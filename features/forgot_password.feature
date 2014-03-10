Feature: User can ask for a password reset
  Scenario: User can get password reset
    Given I am on the Login page
    When I click on Forgot Password
    Then I should see Forgot Password 
    And I fill in email with my address
    Then I use the url to go to change password page
    And fill in a new password and confirmation

    

