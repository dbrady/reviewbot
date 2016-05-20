require 'json'

class Lookup < Sinatra::Base
  post '/lookup' do
    body = JSON.parse(request.body.read)
    message = body["item"]["message"]["message"]
    code = message[5..-1]
    resp = Faraday.get("http://icd10api.com/?code=#{code}&r=json&desc=short")
    data = JSON.parse(resp.body)

    response = {
      message: data["Description"],
      notify: false,
      message_format: "text"
    }.to_json

    content_type :json
    response
  end
end

