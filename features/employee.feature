#Author: DilshanF
#Date Created: 21/09/2019

Feature: REST API Employee Validation

  Scenario: As a User, I want to create an employee
    Given I create an employee with "Dilshan", "25000" and "30"
    When I send a POST request for "http://dummy.restapiexample.com/api/v1/create"
    Then the response status should be "200"
    And the response headers should be:
      | content_type                  | text/html; charset=UTF-8                                   |
      | access_control_expose_headers | Content-Type, X-Requested-With, X-authentication, X-client |
    And the response should have employee data

  Scenario: As a User, I want to Get an employee data
    Given I send a GET request to retrieve employee data
    Then the response status should be "200"
    And the response should have employee data

  Scenario: As a User, I want to Delete an employee
    Given I send a DELETE request to remove employee
    Then the response status should be "200"
    Then the response should have value "successfully! deleted Records"



