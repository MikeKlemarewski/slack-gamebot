module SlackGamebot
  module Commands
    class Lost < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        challenger = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        arguments = expression.split.reject(&:blank?) if expression

        opponents = []
        teammates = [challenger]

        current = :scores
        while arguments && arguments.any?
          argument = arguments.shift
          case argument
          when 'to' then
            current = :opponents
          else
            if current == :opponents
              opponents << ::User.find_by_slack_mention!(client.owner, argument.capitalize!)
            end
          end
        end


        if opponents.any?
          match = ::Match.lose!(team: client.owner, winners: opponents, losers: teammates)
          client.say(channel: data.channel, text: "Match has been recorded! #{match}.", gif: 'loser')
          logger.info "LOST TO: #{client.owner} - #{match}"
        else
          client.say(channel: data.channel, text: "Who did you lose to?")
        end
      end
    end
  end
end
