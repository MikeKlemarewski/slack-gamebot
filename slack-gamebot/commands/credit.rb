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
          client.say(channel: data.channel, text: "Money well spent, #{user.user_name}! Your new balance is $#{new_balance}")
        logger.info "SPEND: #{client.owner} - #{data.user}"
      end
    end

    class Balance < SlackRubyBot::Commands::Base
      command 'balance', '' do |client, data, _match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        current_balance = '%.2f' % [user.credit.to_f/100]
          client.say(channel: data.channel, text: "Your balance is $#{current_balance}")
          logger.info "Balance: #{client.owner} - #{user.user_name}"
      end
    end

    class Credit < SlackRubyBot::Commands::Base
      credit_step = [0, 30, 60, 90, 120, 150, 180, 230, 250]
      command 'update credit' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        if user.captain?
          ranked_players = client.owner.users.ranked
          message = ranked_players.send(:asc, :rank).each_with_index.map do |user, index|
            user.add_credit(credit_step[index])
            
            "#{user.rank}. #{user}"
          end.join("\n")
          client.say(channel: data.channel, text: message)
        else
          client.say(channel: data.channel, text: "Only captains can update credit")
        end
      end

      command 'credit', 'give', '' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        if user.captain?
          expression = match['expression'] if match['expression']
          arguments = expression.split.reject(&:blank?) if expression
          updated_credit = arguments.first.delete('$ ,')
          new_credit = user.add_credit(updated_credit.to_f*100)
          new_balance = '%.2f' % [user.credit.to_f/100]
          client.say(channel: data.channel, text: "Enjoy the cash, #{user.user_name}! Your new balance is $#{new_balance}")
        else
          client.say(channel: data.channel, text: "#{user.user_name} is not a captain. I don't respect your authority.")
        end
        logger.info "CREDIT: #{client.owner} - #{data.user}"
      end
    end
  end
end
