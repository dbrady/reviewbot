require 'json'

require_relative './lib/commands/reviewer'

class Lookup < Sinatra::Base
  post '/ehr-rest-reviewer' do
    content_type :json
    Command::Reviewer.ehr_rest_squad request
  end
end
