#!/usr/bin/env ruby

require 'telegram/bot'

require_relative './lib/secrets.rb'

module WulfBot

  CHAR_LIMIT = 4096 # Max num characters in message

  # Parse the secrets YAML and get the bot's telegram token
  TOKEN = WulfBot::Secrets.secrets["general"]["token"]

  # Holds the registered commands
  @@commands = []

  # Sends a message to Telegram, truncated to the max character limit
  # TODO: Extract this into a helper class
  def self.send_limited(id, text)
    @@bot.api.send_message(chat_id: id, text: text[0,CHAR_LIMIT-1])
  end

  # Register command callbacks
  def self.register_command(command: nil, regex: nil, &callback)
    unless command.nil? ^ regex.nil?
      raise ArgumentError, "Either command or regex must be specified"
    end

    if not command.nil?
      regex = Regexp.new("\\A/" + command + "(@WulfBot)?", "i")
    end

    # Add regex to command list
    @@commands << {command: regex, callback: callback}
  end

  # Main method
  def self.run
    Telegram::Bot::Client.run(TOKEN) do |bot|
      @@bot = bot
      bot.listen do |message|
        # TODO: Better message logging
        puts message.text

        # Iterate over the callbacks
        @@commands.each do |cb|
          unless cb[:command].match(message.text).nil?
            cb[:callback].call(message)
          end
        end
      end
    end

  rescue Telegram::Bot::Exceptions::ResponseError => e
    # If telegram gave a 502, it's safe to restart
    if (e.error_code.to_s == "502")
      puts "Got error 502 from Telegram, restarting in 10 seconds"
      sleep 10
      retry
    else
      puts e
      exit 255
    end

  # Telegram servers occasionally crap out and SSL connections fail. Retry.
  rescue OpenSSL::SSL::SSLError => e
    puts "Error connecting to the API over SSL. Retrying in 10 seconds"
    sleep 10
    retry
  end
end

# Module for plugins
module WulfBot::Plugin
end

# Load plugins
Dir.glob('./plugin/*.rb') do |rb_file|
  require_relative rb_file
end

# Start main method
WulfBot::run
