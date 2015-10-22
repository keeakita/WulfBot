require 'telegram/bot' # Message object
require 'open-uri'

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
        cur_json['code'].upcase == currency.upcase
      end

      if !match.nil?
        return match['rate']
      end
    end

    return false
  end
end
