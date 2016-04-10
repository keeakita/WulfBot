module WulfBot::Plugin::DiscordianDate
  WulfBot::register_command(command: "ddate") do |message|
    response = `ddate '+Today is %A, the %e day of %B in the YOLD %Y. %.%N Have a Chaotic %H!'`

    WulfBot::send_limited(message.chat.id,
                          response.empty? ? "Error getting date" : response)
  end
end
