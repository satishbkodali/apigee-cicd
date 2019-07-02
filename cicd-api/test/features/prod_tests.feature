Feature:
    apigee tests
        
    @POST_call    
    Scenario: Create a record
        Given I set body to {"name":"jane","salary":"10","age":"20"}
        When I POST to /v1/dummyrest/create
        Then response code should be 200
        And response body path $.employee_name should be jane
    @Error    
    Scenario: error check
        Given I set body to {"name":"jane","salary":"10","age":"20"}
        When I POST to /v1/dummyrest/create
        Then response code should be 200
        And response body path $.error should be duplicate_unique_property_exists    
    @GET_call    
    Scenario: retrieve a record
        Given I set Content-type header to application/json
        When I GET /v1/dummyrest/employee/95860
        Then response code should be 200
        And response body path $.employee_name should be Rasheed
        And response body path $.employee_salary should be 123
    @Error
    Scenario: not found record
        Given I set Content-type header to application/json
        When I GET /v1/dummyrest/employee/7483
        Then response code should be 200
        And response body path $.error should be entity_not_found
