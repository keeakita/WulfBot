module WulfBot::Plugin::Emojize

  # Map of characters. For this to work as expected, longer keys must come
  # before shorter keys in the hash.
  @@char_map = {
    'ABCD' => '🔠',
    'BACK' => '🔙',
    'COOL' => '🆒',
    'FREE' => '🆓',
    'SOON' => '🔜',
    '1234' => '🔢',
    'ABC' => '🔤',
    'ATM' => '🏧',
    'END' => '🔚',
    'NEW' => '🆕',
    'TOP' => '🔝',
    'UP!' => '🆙',
    'ZZZ' => '💤',
    '100' => '💯',
    'AB' => '🆎',
    'BK' => '🏦',
    'CL' => '🆑',
    'ID' => '🆔',
    'NG' => '🆖',
    'OK' => '🆗',
    'ON' => '🔛',
    'WC' => '🚾',
    'TM' => '™',
    '10' => '🔟',
    '17' => '📅',
    '24' => '🏪',
    '!?' => '⁉️',
    '!!' => '‼️',
    'A' => '🅰',
    'B' => '🅱',
    'C' => '↪️',
    'D' => '↩️',
    'E' => '📧',
    'F' => '🏁',
    'G' => '⛽️',
    'H' => '🏨',
    'I' => 'ℹ️',
    'K' => '🎋',
    'J' => '🎷',
    'L' => '🕒',
    'M' => 'Ⓜ️',
    'N' => '♑️',
    'O' => '🅾',
    'P' => '🅿️',
    'Q' => '🍳',
    'R' => '®',
    'S' => '💲',
    'T' => '➕',
    'U' => '⛎',
    'V' => '♈️',
    'W' => '〰',
    'X' => '✖️',
    'Y' => '💴',
    'Z' => '⚡️',
    '0' => '0⃣',
    '1' => '1⃣',
    '2' => '2⃣',
    '3' => '3⃣',
    '4' => '4⃣',
    '5' => '5⃣',
    '6' => '6⃣',
    '7' => '7⃣',
    '8' => '8⃣',
    '9' => '9⃣',
    '!' => '❗️',
    '?' => '❓',
    '$' => '💰'
  }

  def self.emojize(string)
    emoj_str = string.upcase

    @@char_map.each_pair do |key, value|
      emoj_str.gsub!(key, value)
    end

    return emoj_str
  end

  # Register a command handler
  WulfBot::register_command(command: "emojize") do |message|
    /\A\/emojize(@WulfBot)?\s+(.+)/ =~ message.text
    if $2.nil?
      WulfBot::send_limited(message.chat.id, "Give me a string to emojize")
    else
      WulfBot::send_limited(message.chat.id, self.emojize($2))
    end
  end
end
