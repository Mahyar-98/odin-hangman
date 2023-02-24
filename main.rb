# This class loads an array of words that the computer guesses a word from when the game starts
class DictionaryLoader
  DICTIONARY_FILE = 'google-10000-english-no-swears.txt'
  attr_reader :words, :dictionary
  def initialize
    @words = []
    File.foreach(DICTIONARY_FILE) do |word|
      word.chomp!
      next if word.length > 12 || word.length < 5

      @words << word
    end
  end
end
