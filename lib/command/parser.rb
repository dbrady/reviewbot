require 'ice_nine'

# Use this over OptionParser for better parsing of what a human might type
# quickly in chat

class Command
  class Parser
    class << self
      def parse command
        singleton.parse command
      end

      private

      def singleton
        @singleton ||= Parser.new
      end
    end

    def parse command
      result = Hash[
        arguments: [],
        options: Hash[
          long:  Hash[],
          short: Hash[],
        ],
      ]

      current_collection = result[:arguments]

      command
        .split
        .each_with_index do |part, index|
          next result[:command] = part.downcase if index == 0

          if part[0] == '-' && part.size == 2 && part != '--'
            key = part[1..-1].to_sym

            current_collection = result[:options][:short][key] ||= []
          elsif part[0..1] == '--' && part.size > 2
            key = part[2..-1].to_sym

            current_collection = result[:options][:long][key] ||= []
          else
            current_collection << part
          end
        end

      IceNine.deep_freeze result
    end
  end
end
