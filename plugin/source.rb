module WulfBot::Plugin::Source
  SRC_URL    = 'https://github.com/oslerw/wulfbot'

  db_name =  ENV['DATABASE'] || 'development'
  commit = `git rev-parse --short HEAD`.strip
  branch = `git rev-parse --abbrev-ref HEAD`.strip

  # Register a command handler
  WulfBot::register_command(command: "sauce") do |message|
    response = "This is WulfBot, commit #{commit} on branch '#{branch}'"\
      ", running with database '#{db_name}'. "\
      "To view my source code or file a bug report, please visit #{SRC_URL}"

    WulfBot::send_limited(message.chat.id, response)
  end
end
