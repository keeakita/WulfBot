# Stores the secrets for the bot

module WulfBot
end

module WulfBot::Secrets
  @@secrets = YAML.load_file('./secrets.yaml')

  def self.secrets
    @@secrets
  end
end

