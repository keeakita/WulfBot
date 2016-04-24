module WulfBot::Plugin::Weewoo
  WOLF   = '🐺'
  SIREN  = '🚨'
  POLICE = '🚔'

  @@r = Random.new()

  WulfBot::register_command(command: 'weewoo') do |message|
    response = ''

    30.times do
      roll = @@r.rand * 3
      if roll > 2
        response += WOLF
      elsif roll > 1
        response += SIREN
      else
        response += POLICE
      end
    end

    WulfBot::send_limited(message.chat.id, response)
  end
end
