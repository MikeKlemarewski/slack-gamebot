module SlackGamebot
  module Commands
    class Help < SlackRubyBot::Commands::Base
      HELP = <<-EOS
I am your friendly Gamebot, here to help.

```
General
-------
hi: be nice, say hi to your bot
team: show your team's info and captains
register <name>: register a player 
unregister <name>: unregister a player
help: get this helpful message

Games
-----
lost to <opponent>: record your loss
defeated <opponent>: record your victory
beat <opponent>: record your victory

Stats
-----
leaderboard : show the leaderboard

Credit
------
balance: display your credit balance
spend <0.50>: spend credit

Captains
--------
promote <player>: promote a user to captain

Premium
-------
reset <team>: reset all stats, start a new season
unregister <player>: remove a player from the leaderboard
```
        EOS
      def self.call(client, data, _match)
        client.say(channel: data.channel, text: [
          HELP,
          SlackGamebot::INFO,
          client.owner.reload.premium? ? nil : client.owner.upgrade_text
        ].compact.join("\n"))
        client.say(channel: data.channel, gif: 'help')
        logger.info "HELP: #{client.owner} - #{data.user}"
      end
    end
  end
end
