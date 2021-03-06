module SlackGamebot
  module Commands
    class Beat < SlackRubyBot::Commands::Base
      command 'beat', 'Beat', 'defeated', 'Defeated', 'humiliated', 'was victorious over' do |client, data, match|
        challenger = ::User.find_create_or_update_by_slack_id!(client, data.user)
        expression = match['expression'] if match['expression']
        arguments = expression.split.reject(&:blank?) if expression

        opponent = ::User.find_by_slack_mention!(client.owner, arguments.first)
        unless opponent
          client.say(channel: data.channel, text: "Who did you defeat?")
        end

        match = ::Match.lose!(team: client.owner, winners: [challenger], losers: [opponent])
        client.say(channel: data.channel, text: "Match has been recorded! #{match}.", gif: 'loser')
        logger.info "DEFEATED: #{client.owner} - #{match}"
      end
    end
  end
end
