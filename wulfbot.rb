#!/usr/bin/env ruby

require 'telegram/bot'
require 'open-uri'
require 'bigdecimal'

require_relative './lib/btc.rb'
require_relative './lib/emojize.rb'
require_relative './lib/points.rb'

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
  when /\A\/btc(@WulfBot)?/i
    # Bitcoin command
    # Check if arg. If not, set to USD
    if (message.text =~ /\A\/btc(@WulfBot)?\s+(.+)/i)
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

  when /\A\/sauce(@WulfBot)?/i
    send_limited(bot, message.chat.id, SRC_URL)

  when /\A\/emojize(@WulfBot)?\s+(.+)/i
    send_limited(bot, message.chat.id, Emojize.emojize($2))

  when /\A\/dogyears(@WulfBot)?\s+([eE\d.-]+)/i
    human_years = BigDecimal($2)
    dog_years = human_years * BigDecimal('7')

    # Make short, readable strings for the human and dog years
    human_str, dog_str = [human_years, dog_years].map do |bigDec|
      bigDec > 1e9 || bigDec < 1e-9 ? bigDec.to_s('E') : bigDec.to_s('F')
    end

    send_limited(bot, message.chat.id,
                 "#{human_str} human years is #{dog_str} dog years.")

  when /\A\/addpoint(@WulfBot)?\s+(.+)/i
    user = $2
    record = Points::getPointRecord(message.chat.id, user)

    # Check for no existing record
    if (record.nil?)
      record = Points::PointRecord.create(group: message.chat.id, user: user)
    end

    record.addpoint!
    send_limited(bot, message.chat.id, record.to_s)

  when /\A\/rmpoint(@WulfBot)?\s+(.+)/i
    user = $2
    record = Points::getPointRecord(message.chat.id, user)

    # Check for no existing record
    if (record.nil?)
      record = Points::PointRecord.create(group: message.chat.id, user: user)
    end

    record.rmpoint!
    send_limited(bot, message.chat.id, record.to_s)

  when /\A\/points(@WulfBot)?\s+(.+)/i
    user = $2
    record = Points::getPointRecord(message.chat.id, user)

    # Check for no existing record
    unless (record.nil?)
      send_limited(bot, message.chat.id, record.to_s)
    else
      send_limited(bot, message.chat.id, "#{user} has no points.")
    end

  when /\A\/top(@WulfBot)?/i
    records = Points::topScores(message.chat.id)

    resp = "Top 5 scores for this chat:\n"
    records.each do |record|
      resp += record.to_s + "\n"
    end

    send_limited(bot, message.chat.id, resp)

  when /\A\/bottom(@WulfBot)?/i
    records = Points::bottomScores(message.chat.id)

    resp = "Bottom 5 scores for this chat:\n"
    records.each do |record|
      resp += record.to_s + "\n"
    end

    send_limited(bot, message.chat.id, resp)
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
    puts "Got error 502 from Telegram, restarting in 10 seconds"
    sleep 10
    main
  else
    puts e
    exit 255
  end
end

# Start main method
main
