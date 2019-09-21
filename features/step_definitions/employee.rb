require_relative '../../lib/employee'
require 'rest-client'
require 'logger'

Given(/^I create an employee with "(.*?)", "(.*?)" and "(.*?)"$/) do |name, salary, age|
  @logger = Logger.new STDOUT
  eName = name + "_" + rand(1..2000).to_s # employee_name_unique_in_DB
  $emp ||= Employee.new(eName, salary, age)
end

When /^I send a (POST|GET|DELETE) request (?:for|to) "([^"]*)"$/ do |*args|
  @logger = Logger.new STDOUT
  request_type = args.shift.downcase
  url = args.shift

  # Don't raise exceptions but return the response
  if (request_type == 'post')
    @response = RestClient.post(url, $emp.to_json) { |response, request, result| response }
  elsif (request_type == 'get')
    @response = RestClient.get(url) { |response, request, result| response }
  elsif (request_type == 'delete')
    @response = RestClient.delete(url) { |response, request, result| response }
  end
  @logger.info ">> Employee: #{$emp.to_json.to_s}"
  @logger.info ">> Request URL: #{url}"
end


Then(/^the request was successful$/) do
  raise %/Expected Successful response code 2xx but was #{@response.code}/ if @response.code < 200 || @response.code >= 300
  @logger.info ">> Return response http code: #{@response.code}"
end

Then(/^the response status should be "(\d+)"$/) do |status_code|
  raise %/Expect #{status_code} but was #{@response.code}/ if @response.code != status_code.to_i
end

And(/^the response headers should be:$/) do |headers|
  @responseHeaders = @response.headers # get the headers from the response
  headers.rows_hash.each do |key, value|
    expect(@responseHeaders.keys).to include(key.to_sym), "Could not find header : #{key} in the response"
    expect(@responseHeaders.values).to include(value), "Could not find header value : #{value} in the response"
  end
end

And(/^the response should have employee data$/) do
  @body = JSON.parse(@response)
  if ($emp.emp_id).equal?(nil)
    expect(@body["id"]).not_to be_empty, "Could not find Employee ID in the response"
    $emp.emp_id = @body["id"]
    @logger.info ">> Successfully Created an Employee with ID: #{$emp.emp_id}"
  else
    #verify the response employee data
    expect(@body["employee_name"]).to eq($emp.emp_name), "Returned invalid Employee Name. But returned: #{@body["employee_name"]}"
    expect(@body["employee_salary"]).to eq($emp.emp_salary), "Returned invalid Employee Salary. But returned: #{@body["employee_salary"]}"
    expect(@body["employee_age"]).to eq($emp.emp_age), "Returned invalid Employee Age. But returned: #{@body["employee_age"]}"
    expect(@body["id"]).to eq($emp.emp_id), "Returned invalid Employee ID"
    @logger.info ">> Response: #{@response.to_s}"
  end
  @logger.info "==========================Test Case Execution End=========================="
end

Given(/^I send a GET request to retrieve employee data$/) do
  url = "http://dummy.restapiexample.com/api/v1/employee/#{$emp.emp_id}"
  step "I send a GET request for \"#{url}\""
end

Given(/^I send a DELETE request to remove employee$/) do
  url = "http://dummy.restapiexample.com/api/v1/delete/#{$emp.emp_id}"
  step "I send a DELETE request for \"#{url}\""
end

Then(/^the response should have value "(.*?)"$/) do |value|
  @data = JSON.parse(@response)
  expect(@data.to_s).to include(value), "Invalid response message. But got: #{@data.to_s}"
  @logger.info ">> Successfully Deleted Employee with ID: #{$emp.emp_id}"
end