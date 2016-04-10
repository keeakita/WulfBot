require 'open-uri'
require 'active_support/inflector'

module WulfBot::Plugin::Bitcoin

  API_URL = "https://bitpay.com/api/rates"
  TTL     = 300

  @@last_fetch = nil
  @@btc = nil

  # Fetches up to date BTC data from the API
  def self.refresh
    @@btc = JSON.parse(open(API_URL).read)
    @@last_fetch = Time.now
    true
  rescue OpenURI::HTTPError
    false
  end

  # Gets the rate of 1 BTC in the given currency
  def self.convert(currency)
    if (@@last_fetch.nil? || Time.now - @@last_fetch >= TTL)
      refresh
    end

    if !@@btc.nil?
      match = @@btc.find do |cur_json|
        cur_json['code'].upcase == currency.upcase ||
          cur_json['name'].upcase == currency.upcase
      end

      if !match.nil?
        return match
      end
    end

    return false
  end

  def self.response_string(currency)
    if (match = convert(currency))
      return "1 Bitcoin is worth #{match['rate']} #{match['name'].pluralize}."
    end
    return "Sorry, #{currency} is not a supported currency."
  end

  # Register a command handler
  WulfBot::register_command(command: "btc") do |message|
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
    elsif currency == 'MAYONNAISE'
      response = "No Patrick, MAYONNAISE is not a currency"
    elsif currency == 'BTC' || currency == 'BITCOIN'
      response = "1 BTC is worth 1 BTC, asshole"
    else
      # Actually fetch
      response = response_string(currency)
    end

    WulfBot::send_limited(message.chat.id, response)
  end
end
