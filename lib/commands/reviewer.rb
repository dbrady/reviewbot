require 'ice_nine'
require 'json'

require_relative '../command'

class Command::Reviewer < Command
  # Want to add a group or a person? All you need to do is update this!
  # Groups automatically get class methods defined for ease of use:
  #
  #   Command::Reviewer.my_group_name request

  GROUPS = IceNine.deep_freeze Hash[
    ehr_rest_squad: %w[
      DJDestefano
      DaveBrady
      JenniferPayne
      JohnMarks
      RobertLude
      TJEakle
      ValerieShoskes
    ],
  ]

  EXCLUDE_DESC = 'Exclude one or more individuals'.freeze
  PEEK_DESC    = "Peek at who's next".freeze
  DEBUG_DESC   = 'Display relevant data to this command'.freeze
  TEST_DESC    = 'Test this feature (no notifications, no changes to internal' \
                 'state, etc.)'.freeze

  command_description 'Request a peer review from the next person in line. ' \
                      'The URL must be to a PR on either our public or ' \
                      'private GitHubs'

  argument 'pull_request_url'

  option('exclude', 'e', EXCLUDE_DESC          ) { [] }
  # option('peek',    'p', PEEK_DESC,    :boolean) { false }
  # option('debug',   'D', DEBUG_DESC,   :boolean) { false }
  # option('test',    'T', TEST_DESC,    :boolean) { false }

  PRIVATE_GIT = /^https:\/\/git\.innova-partners\.com\/.*\/pull\/\d+(?:\/files|\/commits)?$/
  PUBLIC_GIT  = /^https:\/\/(?:www\.)?github\.com\/covermymeds\/.*\/pull\/\d+(?:\/files|\/commits)?$/

  class << self
    GROUPS.keys.each do |group_name|
      define_method group_name do |request|
        new(request, :ehr_rest_squad).response
      end
    end

    def current_next_pick_for group_name
      @next_pick ||= Hash[]

      group = GROUPS[group_name]

      @next_pick[group_name] = group.sample unless @next_pick[group_name]

      @next_pick[group_name]
    end

    def increment_next_pick_for group_name
      next_pick = current_next_pick_for group_name

      group = GROUPS[group_name]

      current_index = group.find_index next_pick

      next_index = (current_index + 1) % group.size

      @next_pick[group_name] = group[next_index]
    end
  end

  def initialize request, group_name
    super request

    @group_name = group_name
    @people     = GROUPS[group_name]

    @excluded_people = option(:exclude).map do |mention_name|
                         mention_name.gsub /^@/, ''
                       end
  end

  private

  attr_reader :people

  def pr_url
    return @pr_url unless @pr_url.nil?

    url = arguments[0]

    @pr_url = url if url && PRIVATE_GIT =~ url || PUBLIC_GIT =~ url
  end

  def generate_response
    return peek_message if option :peek

    return debug_message if option :debug

    return usage if pr_url.nil? || option(:help)

    assigned_person = pick_someone

    if assigned_person == :nobody
      nobody_assigned
    else
      assigned_someone assigned_person
    end
  end

  def exclusions
    @exclusions ||= [
      sender,
      *@excluded_people,
    ].map { |mention_name| mention_name.downcase }
  end

  def pick_someone
    pool = @people.reject do |mention_name|
             exclusions.include? mention_name.downcase
           end

    return :nobody if pool.empty?

    pick = nil

    until pool.include? pick
      pick = self.class.current_next_pick_for @group_name
      self.class.increment_next_pick_for @group_name unless option :test
    end

    pick
  end

  def debug_message
    quiet_text <<-MESSAGE
Next up: #{self.class.current_next_pick_for @group_name}
Ruby version: #{RUBY_VERSION}

Request:

#{JSON.pretty_generate request}
MESSAGE
  end

  def nobody_assigned
    excluded_people = format_mention_name_list @excluded_people

    quiet_text <<-MESSAGE
Everyone was excluded from being picked!

* You, @#{sender}, were excluded because you requested the review
* Those excluded by you: #{excluded_people}

Please try again
MESSAGE
  end

  def assigned_someone assigned_person
    message = "@#{assigned_person}: Please review #{pr_url} for @#{sender}"

    if ! option :test
      loud_text message
    else
      quiet_text message
    end
  end

  def peek_message
    next_person = self.class.current_next_pick_for @group_name
    quiet_text "Next in line is: #{next_person}"
  end
end
