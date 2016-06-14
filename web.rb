require 'json'

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
    people = ["Chad", "Corey", "DJ", "Dave", "Jennifer", "Robert", "TJ"]
    reviewer = people.sample

    response = {
      message: "Your reviewer is: #{reviewer}",
      notify: false,
      message_format: "text",
    }.to_json

    content_type :json
    response
  end
end

