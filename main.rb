# This class loads an array of words that the computer guesses a word from when the game starts
class Dictionary
  DICTIONARY_FILE = 'google-10000-english-no-swears.txt'
  attr_reader :words, :computer_word
  def initialize
    @words = []
    File.foreach(DICTIONARY_FILE) do |word|
      word.chomp!
      next if word.length > 12 || word.length < 5

      @words << word
    end
  end

  def computer_word
    words[rand(words.length)]
  end

  def char_in_word?(char)
    computer_word.include?(char)
  end
end

class Display
  attr_accessor :secret_word
  def initialize(num_char)
    @num_char = num_char
    @secret_word = '_' * num_char
  end

  def update_secret_word(word, char)
    for i in 0..word.length
      secret_word[i] = char if word[i] == char
    end
  end

  def incorrect_guess(char)
    puts "Sorry! The letter '#{char}' does not exist in the word."
  end
end

class Player
  def initialize
  end
end

class Game
  def initialize
    @player = Player.new
    @dictionary = Dictionary.new
    @computer_word = @dictionary.computer_word
  end
end

new_game = Dictionary.new
p new_game.computer_word