class Emojize

  # Map of characters. For this to work as expected, longer keys must come
  # before shorter keys in the hash.
  @@char_map = {
    'BACK' => '🔙',
    'SOON' => '🔜',
    'END' => '🔚',
    'TOP' => '🔝',
    'ZZZ' => '💤',
    'AB' => '🆎',
    'BK' => '🏦',
    'CL' => '🆑',
    'ID' => '🆔',
    'WC' => '🚾',
    'OK' => '🆗',
    'NG' => '🆖',
    'A' => '🅰',
    'B' => '🅱',
    'C' => '↪️',
    'D' => '↩️',
    'E' => '📧',
    'H' => '🏨',
    'I' => 'ℹ️',
    'M' => '♍️',
    'N' => '♑️',
    'O' => '🅾',
    'P' => '🅿️',
    'R' => '®',
    'S' => '💲',
    'T' => '➕',
    'V' => '♈️',
    'X' => '✖️',
    'Y' => '💴'
  }

  # Find the longest key in the map
  @@longest = (@@char_map.max_by do |key, val|
    key.length
  end)[0].length

  def self.emojize(string)
    emoj_str = string.upcase

    @@char_map.each_pair do |key, value|
      emoj_str.gsub!(key, value)
    end

    return emoj_str
  end
end
