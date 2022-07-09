const { Given, When, Then } = require('@cucumber/cucumber');
const assert = require('assert');
const { Console, count } = require('console');
const RESERVE_OUTPUT_FIELD = {
    EmptyStr: '""',
    nullStr: 'null',
}
/*Given Step definitions*/ 
 
Given("I set host and endpoint for test", function () {
    this.host = "https://l761dniu80.execute-api.us-east-2.amazonaws.com";
    this.endpoint = "/default/exercise_api";
});

Given("I want to run {string} method on my endpoint", function (http_method) {
    this.http_method = http_method
});

Given(/^I set (.*) body parameter (.*) with value: (.*)$/, function (param_type, param, param_value) {
    converted_param_value = convert_to_type(param_type, param_value);

    if(!this.data){
        this.data = {};
    }
    
    if(converted_param_value in RESERVE_OUTPUT_FIELD){
        
    }
    this.data[param] = converted_param_value in RESERVE_OUTPUT_FIELD ? RESERVE_OUTPUT_FIELD[converted_param_value] : converted_param_value;
});

Given(/^I set body parameter (.*) as plain text with value: (.*)$/, function (param, param_value) {

    if(!this.data){
        this.data = "?"+ param + "=" + (param_value in RESERVE_OUTPUT_FIELD ? RESERVE_OUTPUT_FIELD[param_value] : param_value);
    }
    else{
        this.data += "&"+ param + "=" + (param_value in RESERVE_OUTPUT_FIELD ? RESERVE_OUTPUT_FIELD[param_value] : param_value);
    }
});

Given(/^I set header parameter (.*) with value: (.*)$/, function (param, param_value) {
    if(!this.headers){
        this.headers = {};
    }

    this.headers[param] = param_value;
});

/*When Step definitions*/ 

When('I submit the request', async function(){
    if(this.data && this.headers){
        var response_value = await submit_request(this.host, this.endpoint, this.http_method, headers = this.headers, data = this.data);
    } else if(this.data){
        var response_value = await submit_request(this.host, this.endpoint, this.http_method, data = this.data);
    } else if (this.headers){
        var response_value = await submit_request(this.host, this.endpoint, this.http_method, this.host, this.endpoint, this.http_method, headers = this.headers);
    } else{
        var response_value = await submit_request(this.host, this.endpoint, this.http_method);
    }
    this.status_code = response_value[0];
    this.response = response_value[1];
});


When('I submit {int} the request with incremental value and main_key values', async function(no_requests){
    var headers = {'Content-type': 'application/json'};
    this.multiple_status_code = []
    for(var i = 0; i < no_requests; i++){
        var data = {"value": "value"+i, "main_key": "main_key"+i,};
        var response_value = await submit_request(this.host, this.endpoint, this.http_method, headers = headers, data = data);
        this.multiple_status_code[i] = response_value[0];
    }
});


When('I submit multiple requests for record deletion',  {timeout: 2 * 5000}, async function(){
    if(typeof this.delete_records !== 'undefined' && this.delete_records.length > 0){
        var headers = {'Content-type': 'application/json'};

        for(var i = 0; i < this.delete_records.length; i++){

            data_for_deletion = { 
                main_key: this.delete_records[i]["main_key"] 
            };

            var response_value = await submit_request(this.host, this.endpoint, this.http_method, headers = headers, data = data_for_deletion);
            this.status_code = response_value[0];
            this.response = response_value[1];
            assert.equal(this.status_code, 200, "Could not delete records.")
        }
    }
});
 
/*Then Step definitions*/ 

Then('I receive status code {int}', function (status_code) {
    assert.equal(this.status_code, status_code, "Status codes are not equal!");
});


Then('Verify that response returned is list of objects with parameters value and main_key', function () {
    assert.ok(this.response.length > 0, "Empty list")

    this.response.forEach(function (item, index) {
        element_keys = Object.keys(item);
        assert.ok(element_keys.length > 0, "Not enough keys in element for index: " + index + ". Elemets: " + item);
        assert.equal(element_keys[0], "value");
        assert.equal(element_keys[1], "main_key");
    });
});


Then('I want to store this value for deletion', function () {
    if(this.response.length > 0){
        this.delete_records = this.response;
    }
});


Then(/^Expect response field (.*) with value: (.*)$/, function (param, param_value) {
    param_value = param_value in RESERVE_OUTPUT_FIELD ? RESERVE_OUTPUT_FIELD[param_value] : param_value;
    assert.equal(this.response[param], param_value, "Parameter values do not match");
});


Then("Expect response to not return added record", function () {
    assert.ok(Object.keys(this.response) == ["value", "main_key"], "Record for value and main_key has been inserted.");
});


Then(/^I receive multiple status codes: (.*)$/, function (status_codes) {
    status_codes = status_codes.split(",")
    for(var i = 0; i < status_codes.length; i++){
        assert.ok(this.multiple_status_code[i] == status_codes[i], "Given status codes do not match at request no: " + (i + 1) + "! Expected: " + status_codes[i]  + " Actual: " + this.multiple_status_code[i]);
    }
});


Then(/^Expect record with (.*): (.*), and it contains (.*) param with value: (.*)$/, function (key_to_get, key_to_get_value, param_to_check, param_to_check_value) {

    count = 0;

    this.response.forEach(function(item){
        if(item[key_to_get] === key_to_get_value){
            assert.equal(item[param_to_check], param_to_check_value, "Parameter does not equal!");
            count++;
        }
    });

    assert.ok(count === 0, "There were multiple records with same key")
});


Then(/^Do not expect record with (.*): (.*)$/, function (key_to_get, key_to_get_value) {
    this.response.forEach(function(item){
        assert.notEqual(item[key_to_get], key_to_get_value, "Parameter has been found and not deleted!");
    });
});


/*Helper functions*/ 

async function submit_request(host, endpoint, http_method, headers = { 'default': 'default' }, data = { default: 'default' }){
    var status_code = "";
    var response = "";
    var url = host+endpoint;
    switch(http_method){
        case "GET":
            var request = await fetch(url, {
                method: http_method
            });
            status_code = request.status;
            response = await (request).json();
            break;
        case "Query_param_POST":
            var request = await fetch(url + data, {
                method: "POST",
                headers: headers
            });
            status_code = request.status;
            response = status_code == 200 ? await (request).json() : null;
            break;

        case "Query_param_PUT":
            var request = await fetch(url + data, {
                method: "PUT",
                headers: headers
            });
            status_code = request.status;
            response = status_code == 200 ? await (request).json() : null;
            break;

        case "Query_param_DELETE":
            var request = await fetch(url + data, {
                method: "DELETE",
                headers: headers
            });
            status_code = request.status;
            response = status_code == 200 ? await (request).json() : null;
            break;
        default:
            var request = await fetch(url, {
                method: http_method,
                headers: headers,
                body: !headers || headers["Content-type"] == "application/json" ? JSON.stringify(data) : data
            });
            status_code = request.status;
            response = status_code == 200 ? await (request).json() : null;
            break;
    }
    return [status_code, response];
}

function convert_to_type(param_type, param_value){
    switch(param_type){
        case "number":
            return Number(param_value);
        case "int":
            return parseInt(param_value);
        case "float":
            return parseFloat(param_value);
        default:
            return param_value;
    }
}