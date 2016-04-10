module WulfBot::Plugin::Uptime
  START_TIME = Time.now

  WulfBot::register_command(command: "uptime") do |message|
    diff = Time.now - START_TIME

    years, days, hours, minutes, seconds = 0

    years = (diff / (60 * 60 * 24 * 365)).to_i
    diff -= years * (60 * 60 * 24 * 365)

    days = (diff / (60 * 60 * 24)).to_i
    diff -= days * (60 * 60 * 24)

    hours = (diff / (60 * 60)).to_i
    diff -= hours * (60 * 60)

    minutes = (diff / 60).to_i
    diff -= minutes * 60

    resp = "Bot has been up for "
    resp += "#{years} years, " if years > 0
    resp += "#{days} days, " if days > 0
    resp += "#{hours} hours, " if hours > 0
    resp += "#{minutes} minutes, " if minutes > 0

    if (years > 0 || days > 0 || hours > 0 || minutes > 0)
      resp += "and "
    end

    resp += "#{diff.to_i} seconds."

    WulfBot::send_limited(message.chat.id, resp)

    end
end
