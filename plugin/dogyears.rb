require 'bigdecimal'

module WulfBot::Plugin::DogYears
  # Register a command handler
  WulfBot::register_command(command: "dogyears") do |message|
    /\A\/dogyears(@WulfBot)?\s+([eE\d.-]+)/ =~ message.text

    if $2.nil?
      WulfBot::send_limited(message.chat.id, "Invalid number of years")
    else
      human_years = BigDecimal($2)
      dog_years = human_years * BigDecimal('7')

      # Make short, readable strings for the human and dog years
      human_str, dog_str = [human_years, dog_years].map do |bigDec|
        bigDec > 1e9 || bigDec < 1e-9 ? bigDec.to_s('E') : bigDec.to_s('F')
      end

      WulfBot::send_limited(message.chat.id,
                   "#{human_str} human years is #{dog_str} dog years.")
    end
  end
end
