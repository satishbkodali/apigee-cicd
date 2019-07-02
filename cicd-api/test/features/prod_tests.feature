Feature:
    apigee tests
        
    @POST_call    
    Scenario: Create a record
        Given I set body to {"name":"jane","salary":"10","age":"20"}
        When I POST to /v1/dummyrest/create
        Then response code should be 200
        And response body path $.entities[0].employee_name should be jane
    @Error    
    Scenario: error check
        Given I set body to {"name":"jane","salary":"10","age":"20"}
        When I POST to /v1/dummyrest/create
        Then response code should be 200
        And response body path $.error should be duplicate_unique_property_exists    
    @GET_call    
    Scenario: retrieve a record
        Given I set Content-type header to application/json
        When I GET /v1/dummyrest/employee/74873
        Then response code should be 200
        And response body path $.entities[0].employee_name should be Muhammad
        And response body path $.entities[0].employee_salary should be 10000
    @Error
    Scenario: not found record
        Given I set Content-type header to application/json
        When I GET /v1/dummyrest/employee/7483
        Then response code should be 200
        And response body path $.error should be entity_not_found
