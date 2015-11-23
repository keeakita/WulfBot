#!/usr/bin/env ruby

require 'telegram/bot'
require 'open-uri'
require 'bigdecimal'

require_relative './lib/btc.rb'
require_relative './lib/emojize.rb'

SRC_URL    = 'https://github.com/oslerw/wulfbot'
CHAR_LIMIT = 4096 # Max num characters in message

# Parse the secrets JSON and get the bot's telegram token
TOKEN = JSON.parse(File.read('./secrets.json'))['token']

# Sends a message to Telegram, truncated to the max character limit
# TODO: Extract this into a helper class
def send_limited(bot, id, text)
  bot.api.send_message(chat_id: id, text: text[0,CHAR_LIMIT-1])
end

# Code executed in the bot message loop
def handle_message(bot, message)
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
  when /\A\/dogyears(@WulfBot)?\s+([\d.-]+)/
    dog_years = BigDecimal($2) * BigDecimal('7')
    send_limited(bot, message.chat.id,
                 "#{$2.to_f} human years is #{dog_years.to_s('F')} dog years.")
  end
end

# Main method
def main
  Telegram::Bot::Client.run(TOKEN) do |bot|
    bot.listen do |message|
      handle_message(bot,message)
    end
  end
rescue Telegram::Bot::Exceptions::ResponseError => e
  # If telegram gave a 502, it's safe to restart
  if (e.error_code.to_s == "502")
    puts "Got error 502 from Telegram, restarting"
    main
  else
    puts e
    exit 255
  end
end

# Start main method
main
