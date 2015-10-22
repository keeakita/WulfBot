#!/usr/bin/env ruby

require 'telegram/bot'
require 'open-uri'

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
      begin
        btc = JSON.parse(open('http://api.coindesk.com/v1/bpi/currentprice.json').read)

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

        # Make sure the hash contains the currency before trying to access it
        elsif !btc['bpi'].has_key?(currency)
          response = "Sorry, " + currency + " is not a supported currency"
        else
          response = "1 BTC is worth " + btc['bpi'][currency]['rate'] + " " + currency
        end

        bot.api.send_message(chat_id: message.chat.id, text: response)

      rescue
        bot.api.send_message(chat_id: message.chat.id, text: "Error making the request, sorry!")
      end
    when '/sauce'
        bot.api.send_message(chat_id: message.chat.id, text: SRC_URL)
    end
  end
end

