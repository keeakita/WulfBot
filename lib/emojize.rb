class Emojize

  @@mapping = {
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
    'S' => '💲',
    'T' => '➕',
    'V' => '♈️',
    'X' => '✖️',
    'Y' => '💴'
  }

  def self.emojize(string)
    arr = string.chars.map do |char|
      @@mapping[char.upcase] || char.upcase
    end

    return arr.join
  end
end
