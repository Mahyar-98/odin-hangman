require 'json'
require 'pry-byebug'
# This class loads an array of words that the computer guesses from when the game starts
class Dictionary
  DICTIONARY_FILE = 'google-10000-english-no-swears.txt'
  attr_reader :words
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

  def char_in_word?(word, char)
    word.include?(char)
  end
end

# This class has the contents that will be shown on the screen for different events
class Display
  attr_accessor :secret_word, :guesses
  def initialize(num_char)
    @num_char = num_char
    @secret_word = '-' * num_char
    @guesses = 'Previous guesses: '
  end

  def welcome
    puts 'Welcome to the hangman!'
    puts '1. Start a new game'
    puts '2. Load a game'
  end

  def secret
    puts "The secret word is: #{@secret_word}"
  end

  def ask_for_letter
    puts 'Please enter a letter (A-Z) (If you want to save the game, type "save"):'
  end

  def invalid_choice(char)
    puts "#{char} is not a valid choice. Choose a letter:"
  end

  def update_secret_word(word, char)
    for i in 0..word.length
      secret_word[i] = char if word[i] == char
    end
  end

  def incorrect_guess(char)
    puts "Wrong guess! The letter '#{char.upcase}' does not exist in the word."
    guesses.concat("#{char.upcase} ")
  end

  def correct_guess(char)
    puts "Nice guess! The letter '#{char.upcase}' exists in the word."
    guesses.concat("#{char.upcase} ")
  end

  def remaining_lives(num)
    if num > 1
      puts "You have #{num} lives left!"
    elsif num == 1
      puts "You have 1 life left! It's your last chance!"
    else
      puts "Sorry! You've run out of lives!"
    end
  end

  def won
    puts "Great job! You've won the game!"
  end

  def lost
    puts "Sorry! You've lost the game. Good luck next time!"
  end

  def save
    puts 'The game was saved successfully!'
  end

  def load
    puts 'The game was loaded successfully!'
  end

  def load_fail
    puts 'The game failed to load!'
  end
end

# This class dictates the rules of the game
class Game
  attr_accessor :player, :dictionary, :display
  def initialize
    @dictionary = Dictionary.new
    @computer_word = @dictionary.computer_word
    @display = Display.new(@computer_word.length)
    @life = 10
  end

  def get_letter
    display.ask_for_letter
    letter = gets.chomp
    save_game if (letter == 'save' || 'SAVE')
    until (letter.length == 1 && letter.match?(/^[[:alpha:]]+$/)) || (letter == 'save' || 'SAVE')
        display.invalid_choice(letter) 
        letter = gets.chomp
    end
    letter.downcase
  end

  def play_turn
    puts "\n\n"
    display.remaining_lives(@life)
    puts display.guesses
    display.secret
    @select_char = get_letter
    return nil if @select_char == 'save'
    if dictionary.char_in_word?(@computer_word, @select_char)
      display.update_secret_word(@computer_word, @select_char)
      display.correct_guess(@select_char)
      puts display.secret_word
    else
      display.incorrect_guess(@select_char)
      @life -= 1
    end
  end

  def result(num_of_lives)
    puts "\n\nThe secret word is << #{@computer_word} >>"
    if num_of_lives.positive?
      display.won
    else
      display.lost
    end
  end

  def play_game
    display.welcome
    @action = gets.chomp
    load_game if @action == '2'
    while display.secret_word.include?('-') && @life.positive? && @select_char != 'save'
      play_turn
    end
    @select_char == 'save'? return : result(@life)
  end

  def save_game
    @game_state = {
      computer_word: @computer_word,
      display: {
        secret_word: @display.secret_word,
        guesses: @display.guesses
      },
      life: @life
    }
    File.write('SAVE_FILE', JSON.generate(@game_state))
    display.save
  end

  def load_game
    if File.exist?('SAVE_FILE')
      @saved_game_state = JSON.parse(File.read('SAVE_FILE'))
      @computer_word = @saved_game_state['computer_word']
      display.secret_word = @saved_game_state['display']['secret_word']
      display.guesses = @saved_game_state['display']['guesses']
      @life = @saved_game_state['life']
      display.load
    else
      display.load_fail
    end
  end
end

new_game = Game.new
new_game.play_game
