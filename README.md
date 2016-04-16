# WulfBot

Good bot. Best friend.

## Overview

WulfBot is a Telegram bot written in Ruby that interfaces with the Telegram Bot
API. It does a bunch of arbitrary, unrelated things that I felt like
implementing.

## Installation

1. Install the proper version of ruby, according to the contents of
   `.ruby-version` (using rbenv or rvm is recommended)
2. `gem install bundler`
3. `bundle install`
4. `rake db:schema:load`
5. Copy `secrets.yaml.sample` to `secrets.yaml` and edit it, setting the token
   to the token given to you by BotFather.

To set up using a production database instead of a development one, edit
`db/config.yml` accordingly, then:

```bash
export DATABASE=production
rake db:schema:load
```

## Running

```bash
bundle exec ruby wulfbot.rb
```

To run with a production database:
```bash
export DATABASE=production
bundle exec ruby wulfbot.rb
```

## Commands

WulfBot accepts the following commands:

- `/btc [cur]`: Gets the conversion rate for Bitcoin into the specified currency
  (3 letter international code). Defaults to USD if no argument given.
- `/sauce`: Posts a link to the bot's source code on GitHub
- `/emojize [phrase]`: Turns the given phrase into emojis. ↪️🅾Ⓜ️🅿️🕒📧➕📧🕒💴 ⛎💲📧🕒📧💲💲.
- `/dogyears [time]`: Converts a time into dog years, using arbitrary precision
  decimal math.
- `/uptime`: Tells how long the bot has been running.
- `/ddate`: Gets the current date in the Discordian calendar system. Requires
  the `ddate` command to be installed.

### Points
A point tracker (think upvotes/downvotes):
- `/addpoint [thing]`: Gives 1 point to thing
- `/rmpoint [thing]`: Removes 1 point from thing
- `/points [thing]`: Checks how many points thing has
- `/top`: Shows the highest scoring things
- `/bottom`: Shows the lowest scoring things

Points are stored per chat and rate limited per chat/person/thing combination.

### Minecraft
Retrieves information about a Minecraft server. Please update `secrets.yaml`
with the settings of the server.
- `/minecraft`: Shows the server description, player count, total slots, and
  list of players online.

## Plugins

Want to write your own plugin for WulfBot? It now has a plugin-ish API, take a
look at files in the `plugin/` directory for examples on how to use it. The
short story is:

```ruby
module MyCoolModule
  # Register a command handler
  WulfBot::register_command(command: "docoolthing") do |message|
    # Do stuff here. This will be run if the user types "/docoolthing".

    # `message` is a Telegram API message object, consult the telegram-bot-ruby
    # project for more information.

    WulfBot::send_limited(message.chat.id, "Yo, this is one cool plugin!")
  end
end
```
