require 'json'

require_relative './lib/commands/reviewer'

class Lookup < Sinatra::Base
  post '/lookup' do
    body = JSON.parse(request.body.read)
    message = body["item"]["message"]["message"]
    code = message[5..-1]
    resp = Faraday.get("http://icd10api.com/?code=#{code}&r=json&desc=long")
    data = JSON.parse(resp.body)

    if data.has_key?("Error")
      message = "Sorry I can't find that ICD Code :("
    else
      message = data["Description"]
    end

    response = {
      message: message,
      notify: false,
      message_format: "text"
    }.to_json

    content_type :json
    response
  end

  post '/reviewer' do
    content_type :json
    Command::Reviewer.ehr_rest_squad request
  end

  post '/ehr-rest-reviewer' do
    content_type :json
    Command::Reviewer.ehr_rest_squad request
  end

  post '/chad' do
    content_type :json
    response = {
      message: "wouldn't you like to know",
      notify: false,
      message_format: "text"
    }.to_json

    response
  end
end
