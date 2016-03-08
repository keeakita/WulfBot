require 'socket'
require 'json'
require 'protobuf'

# TODO: Caching
module MinecraftInfo

  # Fetches the description JSON from a Minecraft server
  # TODO: Use protobuf for real, don't guess at bytes
  def self.get_server_json(server, port=25565)
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

    return JSON.parse(response)
  rescue
    return nil
  end

  # Gets the number of players on the server
  def self.get_minecraft_player_count(server, port=25565)
    resp_json = get_server_json(server, port)
    return "#{resp_json['players']['online']}/#{resp_json['players']['max']}"
  end

  # Gets the list of players on the server by username
  def self.get_minecraft_player_list(server, port=25565)
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

end
