# Stores the secrets for the bot

require 'yaml'

module WulfBot
end

module WulfBot::Secrets
  @@secrets = YAML.load_file('./secrets.yaml')

  def self.secrets
    @@secrets
  end
end

