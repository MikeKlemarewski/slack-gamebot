module SlackGamebot
  module Commands
    class Spend < SlackRubyBot::Commands::Base
      command 'spend', 'spent', '' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
          expression = match['expression'] if match['expression']
          arguments = expression.split.reject(&:blank?) if expression
          spent_credit = arguments.first.delete('$ ,')
          new_credit = user.spend_credit(spent_credit.to_f*100)
          new_balance = '%.2f' % [user.credit.to_f/100]
          client.say(channel: data.channel, text: "Money well spent, #{data.user}! Your new balance is $#{new_balance}")
        logger.info "SPEND: #{client.owner} - #{data.user}"
      end
    end

    class Balance < SlackRubyBot::Commands::Base
      command 'balance', '' do |client, data, _match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        current_balance = '%.2f' % [user.credit.to_f/100]
          client.say(channel: data.channel, text: "Your balance is $#{current_balance}")
        logger.info "Balance: #{client.owner} - #{data.user}"
      end
    end

    class Credit < SlackRubyBot::Commands::Base
      command 'credit', 'give', '' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        if user.captain?
          expression = match['expression'] if match['expression']
          arguments = expression.split.reject(&:blank?) if expression
          updated_credit = arguments.first.delete('$ ,')
          new_credit = user.add_credit(updated_credit.to_f*100)
          new_balance = '%.2f' % [user.credit.to_f/100]
          client.say(channel: data.channel, text: "Enjoy the cash, #{data.user}! Your new balance is $#{new_balance}")
        else
          client.say(channel: data.channel, text: "#{data.user} is not a captain. I don't respect your authority.")
        end
        logger.info "CREDIT: #{client.owner} - #{data.user}"
      end
    end
  end
end
