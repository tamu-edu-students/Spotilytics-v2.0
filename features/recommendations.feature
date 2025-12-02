Feature: Show Recommendations
  As a user
  I want to get insights and similar suggestions for my saved shows
  So that I can discover new content

  Background:
    Given I am logged in to Spotify
    And I have saved shows

  Scenario: User sees recommendation buttons
    When I visit the saved shows page
    Then I should see the AI button "Why?"
    And I should see the AI button "Similar"
