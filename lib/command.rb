require 'ice_nine'

require_relative './command/option'
require_relative './command/parser'

class Command
  class << self
    def options
      @options ||= []
    end

    def arguments
      @arguments ||= []
    end

    def command_description value = nil
      return @command_description if value.nil?
      @command_description = value
    end

    def argument argument_name
      arguments << argument_name
    end

    def option long, short, description, *flags, &default
      options << Option.new(
                   long,
                   short,
                   description,
                   *flags,
                   &default
                 )
    end

    def inherited base
      base.option('help', 'h', 'Display this message', :boolean) { false }
    end
  end

  def initialize request
    body = JSON.parse request.body.read, symbolize_names: true

    @request = IceNine.deep_freeze body
  end

  def response
    if option :help
      usage
    else
      generate_response
    end.to_json
  end

  private

  attr_reader :request

  def command
    _parsed[:command]
  end

  def arguments
    _parsed[:arguments]
  end

  def option id
    option = self
               .class
               .options
               .find { |option| option.is? id }

    return nil unless option

    option.value_from _parsed[:options]
  end

  def sender
    @request[:item][:message][:from][:mention_name]
  end

  def message
    @request[:item][:message][:message]
  end

  def _parsed
    @_parsed ||= Parser.parse message
  end

  def quiet_text message
    Hash[
      message:        message,
      message_format: 'text',
      notify:         false,
    ]
  end

  def loud_text message
    Hash[
      message:        message,
      message_format: 'text',
      notify:         false,
    ]
  end

  def format_mention_name_list input
    input
      .map { |mention_name| '@' + mention_name }
      .join(', ')
  end

  def usage
    argument_text = self
                      .class
                      .arguments
                      .map { |argument_name| "<#{argument_name}>" }
                      .join(' ')

    option_text = self
                    .class
                    .options
                    .map do |option|
                      short = unless option.short.nil? || option.short.empty?
                                "-#{option.short}"
                              else
                                nil
                              end

                      long = unless option.long.nil? || option.long.empty?
                               "--#{option.long}"
                             else
                               nil
                             end

                      option_tag = [ short, long ]
                                     .compact
                                     .join ', '

                      "\t\t#{option_tag}\n\t\t\t\t#{option.description}"
                    end
                    .join("\n")

    quiet_text <<-USAGE
#{self.class.command_description}

Usage: #{command} #{argument_text}

Options:
#{option_text}
USAGE
  end
end
