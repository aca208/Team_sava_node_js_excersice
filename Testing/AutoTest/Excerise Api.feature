Feature: Verify all Endpoints

    Background: Set endpoint for test
        Given I set host and endpoint for test
            And I want to run "GET" method on my endpoint
        When I submit the request
        Then I receive status code 200
            And I want to store this value for deletion
        Given I want to run "DELETE" method on my endpoint
        When I submit multiple requests for record deletion
        Then I receive status code 200
    

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


    Scenario Outline: Set valid specific record in data
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


    Scenario Outline: Set invalid specific record in data
        Given I want to run "PUT" method on my endpoint
            And I set <value_ex_type> body parameter value with value: <value_ex>
            And I set <main_key_ex_type> body parameter main_key with value: <main_key_ex>
            And I set header parameter Content-type with value: application/json
        When I submit the request
        Then I receive status code 200
            And Expect response to not return added record
        
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


