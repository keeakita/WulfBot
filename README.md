# WulfBot

Good bot. Best friend.

## Overview

WulfBot is a Telegram bot written in Ruby that interfaces with the Telegram Bot
API. It does a bunch of arbitrary, unrelated things that I felt like
implementing.

## Commands

WulfBot accepts the following commands:

- `/btc [cur]`: Gets the conversion rate for Bitcoin into the specified currency
  (3 letter international code). Defaults to USD if no argument given.
- `/sauce`: Posts a link to the bot's source code on GitHub
- `/emojize [phrase]`: Turns the given phrase into emojis. ↪️🅾Ⓜ️🅿️🕒📧➕📧🕒💴 ⛎💲📧🕒📧💲💲.
- `/dogyears [time]`: Converts a time into dog years, using arbitrary precision
  decimal math.
- `/uptime`: Tells how long the bot has been running.

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
