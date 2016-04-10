require 'socket'
require 'json'
require 'protobuf'
require 'active_support/cache'

require_relative '../lib/secrets.rb'

module WulfBot::Plugin::Minecraft
  MC_INFO = WulfBot::Secrets.secrets["minecraft"]

  # Cache for requests, to avoid flooding a server
  @@json_cache = ActiveSupport::Cache::MemoryStore.new

  # Fetches the description JSON from a Minecraft server
  # TODO: Use protobuf for real, don't guess at bytes
  def self.get_server_json(server, port=25565)
    cached = @@json_cache.read("#{server}:#{port}")

    return cached unless cached.nil?

    sock = TCPSocket.new(server, port)

    # Array of bytes to send
    bytes = []

    # First byte is the length of the hostname + 6
    bytes << (server.size + 6)

    # No idea what this is
    bytes.concat([0x00, 0x6b])

    # Next byte is length of just the hostname
    bytes << server.size

    # Now write the hostname
    bytes.concat(server.unpack('C*'))

    # No idea what this is
    bytes.concat([0x63, 0xdd, 0x01, 0x01, 0x00])

    sock.write(bytes.pack('C*'))
    sock.flush

    # Read a varint to get the message size
    size = Protobuf::Varint.decode(sock)

    # Read the rest of the message
    response = sock.read(size)

    # Search forward for "{", discarding anything bfore it
    json_start_pos = response.index("{")
    response = response[json_start_pos..-1]

    json_resp = JSON.parse(response)
    @@json_cache.write("#{server}:#{port}", json_resp, expires_in: 1.minutes)

    return json_resp
  end

  # Gets the number of players on the server
  def self.get_player_count(server, port=25565)
    resp_json = get_server_json(server, port)
    return resp_json['players']['online']
  end

  # Gets the total number of open slots on a server
  def self.get_number_slots(server, port=25565)
    resp_json = get_server_json(server, port)
    return resp_json['players']['max']
  end

  # Gets the text description of the server
  def self.get_description(server, port=25565)
    resp_json = get_server_json(server, port)

    # Check for an older style response
    if (resp_json['description'].is_a? String)
      return resp_json['description']
    else
      return resp_json['description']['text']
    end
  end

  # Gets the list of players on the server by username
  def self.get_player_list(server, port=25565)
    player_list = ""
    resp_json = get_server_json(server, port)

    resp_json['players']['sample'].each do |player|
      player_list += player['name'] + "\n";
    end

    remaining = resp_json['players']['sample'].size - resp_json['players']['online']

    if remaining > 0
      player_list += "... And #{remaining} others"
    end

    return player_list
  end

  # Register a command handler
  WulfBot::register_command(command: "minecraft") do |message|
    # Is the server information configured?
    if MC_INFO.nil?
      WulfBot::send_limited(message.chat.id, "Minecraft plugin not configured")

    # Is this chat allowed to use this command?
    elsif !MC_INFO["restrict"].include?(message.chat.id)
      WulfBot::send_limited(message.chat.id,
                   "This chat does not have permission to use this command.")
    else
      begin
        player_count = get_player_count(MC_INFO["server"], MC_INFO["port"])

        max_slots = get_number_slots(MC_INFO["server"], MC_INFO["port"])

        description = get_description(MC_INFO["server"], MC_INFO["port"])

        resp = "\"#{description}\"\n"
        resp += "Current players: #{player_count}/#{max_slots}\n"

        if (player_count > 0)
          resp += get_player_list(MC_INFO["server"], MC_INFO["port"])
        end

        WulfBot::send_limited(message.chat.id, resp)
      rescue => e
        puts e
        puts e.backtrace
        WulfBot::send_limited(message.chat.id, "Error getting server stats")
      end
    end
  end
end
