module WulfBot::Plugin::BedTime

  # Average time for a sleep cycle (seconds)
  SLEEP_INTERVAL = 90 * 60

  # Average time it takes to fall asleep (seconds)
  SLEEP_DELAY = 14 * 60

  # Register a command handler
  WulfBot::register_command(command: "bedtime") do |message|

    now = Time.now
    times = ""

    (1..6).each do |cycle|
      times += (now + SLEEP_DELAY + cycle * SLEEP_INTERVAL).strftime('%H:%M ')
    end

    WulfBot::send_limited(message.chat.id,
                          "You should wake up at: #{times}(EST)")
  end
end
