#!/usr/bin/env ruby

require 'telegram/bot'
require 'open-uri'

require_relative './lib/btc.rb'
require_relative './lib/emojize.rb'

SRC_URL    = 'https://github.com/oslerw/wulfbot'
CHAR_LIMIT = 4096 # Max num characters in message

# Sends a message to Telegram, truncated to the max character limit
# TODO: Extract this into a helper class
def send_limited(bot, id, text)
  bot.api.send_message(chat_id: id, text: text[0,CHAR_LIMIT-1])
end

token = JSON.parse(File.read('./secrets.json'))['token']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|

    # TODO: Remove this temporary line or print more helpful info
    puts message.text

    # Check for a command
    case message.text
    when /\A\/btc(@WulfBot)?/
      # Bitcoin command
      # Check if arg. If not, set to USD
      if (message.text =~ /\A\/btc(@WulfBot)?\s+(.+)/)
        currency = $2
      else
        currency = 'USD'
      end

      currency.upcase!

      # Easter Eggs
      if currency == 'GREEN'
        response = "GREEN is not a creative color"
      elsif currency == 'MAYONAISE'
        response = "No Patrick, MAYONAISE is not a currency"
      elsif currency == 'BTC' || currency == 'BITCOIN'
        response = "1 BTC is worth 1 BTC, asshole"
      else
        # Actually fetch
        response = BitcoinRate.response_string(currency)
      end

      send_limited(bot, message.chat.id, response)
    when '/sauce'
      send_limited(bot, message.chat.id, SRC_URL)
    when /\A\/emojize(@WulfBot)?\s+(.+)/
      send_limited(bot, message.chat.id, Emojize.emojize($2))
    end
  end
end
