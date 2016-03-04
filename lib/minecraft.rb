require 'socket'
require 'json'
require 'protobuf'

module MinecraftInfo

  # TODO: Use protobuf for real, don't guess at bytes
  def self.get_minecraft_player_count(server, port=25565)
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

    resp_json = JSON.parse(response)
    return "#{resp_json['players']['online']}/#{resp_json['players']['max']}"
  rescue
    return "Error"
  end

end
