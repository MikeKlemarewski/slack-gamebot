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
            if !user.spend_credit(spent_credit)
              message = "You can't spend more credit than you have."
            else
              message = "Money well spent, #{user.user_name}! Your new balance is $#{Credit.format_credit(user.credit)}"
            end
            client.say(channel: data.channel, text: message)
          else
            client.say(channel: data.channel, text: "You can't spend negative credit...you sneaky dog")
          end

        logger.info "SPEND: #{client.owner} - #{data.user}"
      end

      credit_step = [0, 30, 60, 90, 120, 150, 180, 210, 225, 250]
      command 'update credit' do |client, data, match|
        if data.user === 'U2ZBZT2MN'
          last_elo = nil
          last_credit = nil

          ranked_players = client.owner.users.ranked
          message = ranked_players.send(:asc, :rank).each_with_index.map do |user, index|
            if user.elo === last_elo
              # If tied with the last player, they get the same credit
              user.add_credit(last_credit)
            else
              user.add_credit(credit_step[index])
              last_credit = credit_step[index]
              last_elo = user.elo
            end
            user.record_elo()
            
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
