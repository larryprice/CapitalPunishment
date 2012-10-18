# This file contains all logic for the CapitalPunishment web app.
# Larry Price 2012

require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'singleton'

class CapitalPunishment < Sinatra::Base
  get '/' do
    @result = ''
    set_game_variables("World")
    erb :CountriesAndCapitals
  end

  get '/World' do
    @result = ''
    set_game_variables("World")
    erb :CountriesAndCapitals
  end

  get '/UnitedStates' do
    @result = ''
    set_game_variables("UnitedStates")
    erb :CountriesAndCapitals
  end

  get '/Canada' do
    @result = ''
    set_game_variables("Canada")
    erb :CountriesAndCapitals
  end

  get '/Mexico' do
    @result = ''
    set_game_variables("Mexico")
    erb :CountriesAndCapitals
  end

  post '/check_answer' do
    game_data = get_game_data(params[:answer])

    unless game_data.nil? || game_data.size != 4
      check_answer(game_data[:mode], game_data[:type], game_data[:question], game_data[:answer])
      set_game_variables(game_data[:mode])
    else
      handle_unexpected_nil
    end

    erb :CountriesAndCapitals
  end

  post '/toggle' do
    @result = ''
    game_data = get_game_data(params[:mode_image])

    if game_data.nil? || game_data.count < 2
      @game_type = :CAPITALS
      set_game_variables("World")
    else
      if game_data[:type] == :CAPITALS
        @game_type = :COUNTRIES
      else
        @game_type = :CAPITALS
      end
      set_game_variables(game_data[:mode])
    end
    
    erb :CountriesAndCapitals
  end

  def set_game_variables(game_mode)
    if @game_mode.nil?
      @game_mode = game_mode
    end

    if @game_type.nil?
      if params[:mode_image].nil? && params[:answer].nil?
        @game_type = :CAPITALS
      else
        if !params[:mode_image].nil?
          @game_type = get_game_data(params[:mode_image])[:type]
        elsif !params[:answer].nil?
          @game_type = get_game_data(params[:answer])[:type]
        end
      end
    end

    game_var = get_class_instance(game_mode)

    @class_string = game_var.get_class_name_for_image
    @version = game_var.get_version_info

    question_map = game_var.generate_question_information(@game_type)

    @question_statement = @game_type == :CAPITALS ? "What is the capital of" : "Whose capital is"
    @question = question_map[:question]
    @all_answers = question_map[:all_answers]
  end

  def handle_unexpected_nil
    set_game_variables("World")
    @result = "Something went wrong. I'll reset the game for you."
  end

  def get_answer_value(answer = nil)
    answer_value = ''
    unless @game_mode.nil?
      answer_value += @game_mode.gsub(' ', '_')
      unless @game_type.nil?
        answer_value += '@' + @game_type.to_s
        unless @question.nil?
          answer_value += '@' + @question.gsub(' ', '_')
          unless answer.nil?
            answer_value += '@' + answer.gsub(' ', '_')
            return answer_value
          else
            return answer_value
          end
        else
          return answer_value
        end
      else
        return answer_value
      end
    end

    return nil
  end

  def get_game_data(answer_value)
    if answer_value.nil?
      return nil
    end
    vals = answer_value.split('@')

    data = Hash.new
    if vals.count > 0
      data[:mode] = vals[0].gsub('_', ' ')
      if vals.count > 1
        data[:type] = vals[1].to_sym
        if vals.count > 2
          data[:question] = vals[2].gsub('_', ' ')
          if vals.count > 3
            data[:answer] = vals[3].gsub('_', ' ').gsub('/', '')
          end
        end
      end
    end

    return data
  end

  def get_class_instance(mode)
    if mode == "World"
      game_var = World.instance
    elsif mode == "UnitedStates"
      game_var = UnitedStates.instance
    elsif mode == "Canada"
      game_var = Canada.instance
    elsif mode == "Mexico"
      game_var = Mexico.instance
    end
  end

  def check_answer(mode, type, question, answer)
    game_var = get_class_instance(mode)

    unless game_var.nil?
      @result = game_var.check_answer(type, question, answer)
    else
      handle_unexpected_nil
    end
  end
end

#Base class for flavors of CapitalPunishment game
class CountriesAndCapitalsBase
  def load_data
    @data = Nokogiri::HTML(open(@url))
  end

  def initialize
    if !@url.nil?
      load_details(load_data)
      load_readme_info
    end
  end

  def generate_question_information(game_type)
    state_data = Hash.new
    state = @info.keys[Random.rand(@info.count)]
    capitals = @info[state]

    if game_type == :CAPITALS
      state_data[:question] = state
      state_data[:answer] = capitals[Random.rand(capitals.count)]
      state_data[:all_answers] = generate_answers_for_capitals(state_data[:answer], state_data[:question])
    elsif game_type == :COUNTRIES
      state_data[:question] = capitals[Random.rand(capitals.count)]
      state_data[:answer] = state
      state_data[:all_answers] = generate_answers_for_states(state_data[:answer])
    end

    return state_data
  end
  
  def generate_answers_for_capitals(correct_answer, question)
    answers = Array.new
    answers << correct_answer
    filtered_data = @info.select { |state, capital| state != question }

    while answers.count < 5
      incorrect_key = filtered_data.get_rand_key
      incorrect_value = filtered_data[incorrect_key]

      answer_to_add = incorrect_value[Random.rand(incorrect_value.count)]
      answers << answer_to_add unless answers.include?(answer_to_add)
    end

    return answers.sort_by {rand}
  end

  def generate_answers_for_states(correct_answer)
    answers = Array.new
    answers << correct_answer
    filtered_data = @info.select { |state, capital| state != correct_answer }
    answers += filtered_data.get_rand_keys(4)

    return answers.sort_by {rand}
  end

  def check_answer(type, question, answer)
    if type == :CAPITALS
      if @info[question].include? answer
        return "Correct! #{answer} is the capital of #{question}."
      else
        return "#{answer} is not the capital of #{question}. Try again later."
      end
    elsif type == :COUNTRIES
      if @info[answer].include? question
        return "Correct! The capital of #{answer} is #{question}."
      else
        return "The capital of #{answer} is not #{question}. Try again later."
      end
    else
      return nil
    end
  end

  def load_details(data)
    @info = Array.new
  end

  def get_class_name_for_image
    self.class.name.downcase
  end

  def get_version_info
    @version
  end

  def load_readme_info
    if @version.nil?
      basedir = '.'
      readme = Dir.glob("README").first
      unless readme.nil?
        file = File.open(readme)
        @version = file.readline  # first line is version
        file.close
      else
        @version = "Capital Punishment"
      end
    end
  end
end

# Class for loading data for worldwide states and capitals
class World < CountriesAndCapitalsBase
  include Singleton

  def initialize
    @url = "http://en.wikipedia.org/wiki/List_of_national_capitals"
    super
  end

  def load_details(data)
    @info = Hash.new

    data.xpath("//table[@class='wikitable sortable']/tr").each do |row|

      country = row.at_xpath('td[2]/b/a/text()').to_s.strip
      if country.nil? || country.empty?
        country = row.at_xpath('td[2]/a/text()').to_s.strip
        next if country.nil? || country.empty?
      end

      if country != 'Tonga'
        @info[country] = get_capital(row)
      else
        @info[country] = ['Nuku\'alofa']
      end
    end
  end

  def get_capital(row)
    capitals = Array.new
    row.xpath('td[1]/a/text()').each { |cap| capitals << cap.to_s.strip }

    capitals
  end
end

# Class for loading data for US States and Capitals
class UnitedStates < CountriesAndCapitalsBase
  include Singleton

  def initialize
    @url = "http://en.wikipedia.org/wiki/List_of_capitals_in_the_United_States"
    super
  end

  def load_details(data)
    @info = Hash.new

    data.xpath("//table[@class='wikitable sortable']/tr").each do |row|

      state = row.at_xpath('td[1]/a/text()').to_s.strip
      next if state.nil? || state.empty?

      @info[state] = [row.at_xpath('td[4]/a/text()').to_s.strip]
    end
  end
end

# Class for loading Canada data
class Canada < CountriesAndCapitalsBase
  include Singleton

  def initialize
    @url = "http://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada"
    super
  end

  def load_details(data)
    @info = Hash.new

    data.xpath("//table[@class='wikitable sortable']/tr").each do |row|

      province = row.at_xpath('th[3]/a/text()').to_s.strip
      next if province.nil? || province.empty?
      
      @info[province] = [row.at_xpath('td[2]/a/text()').to_s.strip]
    end
  end
end

# Class to load data for Mexico
class Mexico < CountriesAndCapitalsBase
  include Singleton

  def initialize
    @url = "http://en.wikipedia.org/wiki/List_of_capitals_in_Mexico"
    super
  end

  def load_details(data)
    @info = Hash.new

    data.xpath("//table[@class='toc']/tr").each do |row|

      state = row.at_xpath('td[1]/a/text()').to_s.strip
      next if state.nil? || state.empty?

      @info[state] = [row.at_xpath('td[2]/a/text()').to_s.strip]
    end
  end
end

# Extensions for Hash class
class Hash
  def get_rand_key
    self.get_rand_keys(1)[0]
  end

  def get_rand_keys(num_values)
    random_keys = Array.new
    while random_keys.size < num_values && random_keys.size < self.size
      key = self.keys[Random.rand(self.size)]
      if !random_keys.include? key
        random_keys << key
      end
    end

    random_keys
  end
end
