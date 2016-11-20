module SlackGamebot
  module Commands
    class Register < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        expression = match['expression'] if match['expression']

        arguments = expression.split.reject(&:blank?) if expression
        username = if arguments then arguments.first else data.user end

        ts = Time.now.utc
        user = ::User.find_create_or_update_by_slack_id!(client, username)
        user.register! if user && !user.registered?
        message = if user.created_at >= ts
                    "Welcome <#{user.user_name}>! You're ready to play."
                  elsif user.updated_at >= ts
                    "Welcome back <#{user.user_name}>, I've updated your registration."
                  else
                    "Welcome back <#{user.user_name}>, you're already registered."
        end
        message += " You're also team captain." if user.captain?
        client.say(channel: data.channel, text: message, gif: 'welcome')
        logger.info "REGISTER: #{client.owner} - #{data.user}"
        user
      end
    end
  end
end
