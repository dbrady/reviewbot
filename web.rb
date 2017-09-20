require 'json'

require_relative './lib/commands/reviewer'

class Lookup < Sinatra::Base
  post '/ehr-rest-reviewer' do
    content_type :json
    Command::Reviewer.ehr_rest_squad request
  end

  get '/poo' do
    # You do Hello World YOUR way, I'll do it mine
    "One time I went poo so hard it ran down into my shoe"
  end
end
