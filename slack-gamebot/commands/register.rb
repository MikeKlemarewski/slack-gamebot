module SlackGamebot
  module Commands
    class Register < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        expression = match['expression'] if match['expression']
        p expression
        arguments = expression.split.reject(&:blank?) if expression

        if expression.nil? || arguments.empty?
          message = "Please tell me who to register"
          client.say(channel: data.channel, text: message)
          return
        end

        username = arguments.first

        ts = Time.now.utc
        user = ::User.find_create_or_update_by_slack_id!(client, username)
        user.register! if user && !user.registered?
        message = if user.created_at >= ts
                    "Welcome <@#{username}>! You're ready to play."
                  elsif user.updated_at >= ts
                    "Welcome back <@#{username}>, I've updated your registration."
                  else
                    "Welcome back <@#{username}>, you're already registered."
        end
        message += " You're also team captain." if user.captain?
        client.say(channel: data.channel, text: message, gif: 'welcome')
        logger.info "REGISTER: #{client.owner} - #{data.user}"
        user
      end
    end
  end
end
