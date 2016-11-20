module SlackGamebot
  module Commands
    class Credit < SlackRubyBot::Commands::Base
      def self.format_credit(credit)
        '%.2f' % [credit.to_f/100]
      end

      command 'balance', '' do |client, data, _match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        current_balance = '%.2f' % [user.credit.to_f/100]
        client.say(channel: data.channel, text: "Your balance is $#{current_balance}")
        logger.info "Balance: #{client.owner} - #{user.user_name}"
      end

      command 'spend', 'spent', '' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
          expression = match['expression'] if match['expression']
          arguments = expression.split.reject(&:blank?) if expression

          spent_credit = arguments.first.delete('$ ,').to_f * 100
          unless spent_credit < 0
            user.spend_credit(spent_credit)
            message = "Money well spent, #{user.user_name}! Your new balance is $#{Credit.format_credit(user.credit)}"
            client.say(channel: data.channel, text: message)
          else
            client.say(channel: data.channel, text: "You can't spend negative credit...you sneaky dog")
          end

        logger.info "SPEND: #{client.owner} - #{data.user}"
      end

      credit_step = [0, 30, 60, 90, 120, 150, 180, 230, 250]
      command 'update credit' do |client, data, match|
        if data.user === 'U2ZBZT2MN'
          ranked_players = client.owner.users.ranked
          message = ranked_players.send(:asc, :rank).each_with_index.map do |user, index|
            user.add_credit(credit_step[index])
            
            "#{user.rank}. #{user}"
          end.join("\n")
          client.say(channel: data.channel, text: message)
        else
          client.say(channel: data.channel, text: "Only Mike can update credit")
        end
      end

      command 'credit', 'give', '' do |client, data, match|
        user = ::User.find_create_or_update_by_slack_id!(client, data.user)
        if user.captain?
          expression = match['expression'] if match['expression']
          arguments = expression.split.reject(&:blank?) if expression
          updated_credit = arguments.first.delete('$ ,')
          user.add_credit(updated_credit.to_f*100)
          message = "Enjoy the cash, #{user.user_name}! Your new balance is $#{Credit.format_credit(user.credit)}"
          client.say(channel: data.channel, text: message)
        else
          client.say(channel: data.channel, text: "#{user.user_name} is not a captain. I don't respect your authority.")
        end
        logger.info "CREDIT: #{client.owner} - #{data.user}"
      end
    end
  end
end
