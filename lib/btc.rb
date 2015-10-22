require 'telegram/bot' # Message object
require 'open-uri'
require 'active_support/inflector'

class BitcoinRate
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
      self.refresh
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
    if (match = self.convert(currency))
      return "1 Bitcoin is worth #{match['rate']} #{match['name'].pluralize}."
    end
    return "Sorry, #{currency} is not a supported currency."
  end
end
