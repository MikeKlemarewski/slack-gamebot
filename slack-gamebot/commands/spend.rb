module SlackGamebot
  module Commands
    class Spend < SlackRubyBot::Commands::Base
      command 'spend', 'spent', '' do |client, data, _match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
          client.say(channel: data.channel, text: "#{data.user} spent money!")
        logger.info "SPEND: #{client.owner} - #{data.user}"
      end
    end
    class Credit < SlackRubyBot::Commands::Base
      command 'credit', 'give', '' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        if user.captain?
          expression = match['expression'] if match['expression']
          arguments = expression.split.reject(&:blank?) if expression
          new_credit = user.add_credit(arguments.first.to_i)
          client.say(channel: data.channel, text: "Enjoy the cash, #{data.user}! Your new balance is #{new_credit}")
        else
          client.say(channel: data.channel, text: "#{data.user} is not a captain. I don't respect your authority.")
        end
        logger.info "CREDIT: #{client.owner} - #{data.user}"
      end
    end
  end
end
