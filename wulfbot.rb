#!/usr/bin/env ruby

require 'telegram/bot'
require 'open-uri'

require_relative './lib/btc.rb'
require_relative './lib/emojize.rb'

SRC_URL = 'https://github.com/oslerw/wulfbot'

token = JSON.parse(File.read('./secrets.json'))['token']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|

    # TODO: Remove this temporary line or print more helpful info
    puts message.text

    # Check for a command
    case message.text
    when /\A\/btc/
      # Bitcoin command
      # Check if arg. If not, set to USD
      if (message.text =~ /\A\/btc\s+(.+)/)
        currency = $1
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

      bot.api.send_message(chat_id: message.chat.id, text: response)
    when '/sauce'
      bot.api.send_message(chat_id: message.chat.id, text: SRC_URL)
    when /\A\/emojize\s+(.+)/
      bot.api.send_message(chat_id: message.chat.id, text: Emojize.emojize($1))
    end
  end
end
