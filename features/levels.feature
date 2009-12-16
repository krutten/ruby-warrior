Feature: Play levels
  In order to play ruby warrior
  As a player
  I want to advance through levels or retry them
  
  Background:
    Given no profile at "tmp"
  
  Scenario: Pass first level, fail second level
    Given a profile named "Joe" on "beginner"
    When I copy fixture "walking_player.rb" to "tmp/ruby-warrior/joe-beginner/player.rb"
    And I run rubywarrior
    And I choose "Joe - beginner - level 1" for "profile"
    And I answer "y" to "next level"
    Then I should see "directory for the next level"
    When I run rubywarrior
    And I choose "Joe - beginner - level 2" for "profile"
    And I answer "y" to "clues"
    Then I should see "warrior.feel.empty?"
  
  Scenario: Retry first level
    Given a profile named "Joe" on "beginner"
    When I copy fixture "walking_player.rb" to "tmp/ruby-warrior/joe-beginner/player.rb"
    And I run rubywarrior
    And I choose "Joe - beginner - level 1" for "profile"
    And I answer "n" to "next level"
    Then I should see "current level"
    When I run rubywarrior
    Then I should see "Joe - beginner - level 1"
  
  @focus
  Scenario: Replay levels as epic when finishing last level with grades
    When I copy fixture "short-tower" to "towers/short"
    Given a profile named "Bill" on "short"
    When I copy fixture "walking_player.rb" to "tmp/ruby-warrior/bill-short/player.rb"
    And I run rubywarrior
    And I choose "Bill - short - level 1" for "profile"
    Then I answer "y" to "next level"
    And I should see "next level"
    When I run rubywarrior
    And I choose "Bill - short - level 2" for "profile"
    Then I answer "y" to "epic"
    And I should see "epic mode"
    When I run rubywarrior
    And I choose "Bill - short - first score 34 - epic score 0" for "profile"
    Then I should see "Level Grade: S"
    When I run rubywarrior
    And I choose "Bill - short - first score 34 - epic score 34" for "profile"
    Then I should see "grade for this tower"
    When I run rubywarrior
    Then I should see "Bill - short - first score 34 - epic score 34"
