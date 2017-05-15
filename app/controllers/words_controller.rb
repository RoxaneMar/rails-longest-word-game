require 'open-uri'
require 'json'

class WordsController < ApplicationController
  def game
    @grid = generate_grid(10)
    session[:grid] = @grid
    @start_time = Time.now
    session[:start_time] = @start_time.to_i
    session[:score] ||= []
  end

  def score
    @end_time = Time.now.to_i
    @answer = params[:query]
    # @grid = params[:grid]
    # @start_time = params[:start_time].to_time
    @result = run_game(@answer, session[:grid], session[:start_time], @end_time)
    @score = @result[:score]
    session[:score] << @score
    @time = @result[:time].to_i
    @translation = @result[:translation]
    @message = @result[:message]
    @avg_score = avg_something(session[:score])
    # @avg_time = avg_something(session[:results], 'time')
    @nb = session[:score].length
  end

  private

def avg_something(scores)
  sum = 0
  scores.each { |score| sum += score}
  return sum / scores.length
end

def generate_grid(grid_size)
  # TODO: generate random grid of letters
  return (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
end

def translation(attempt)
  key = 'b6c07608-c801-4b14-a1dd-54d77f918c99'
  url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}&input=#{attempt}"
  user_translation = open(url).read
  user = JSON.parse(user_translation)
  return user["outputs"][0]["output"]
end

def validity_test(attempt, grid)
  # grid.sort.join.downcase.include?(attempt.downcase.split('').sort.join)
  array = attempt.upcase.split('')
  array.all? { |letter| grid.include?(letter) && attempt.upcase.count(letter) <= grid.count(letter) }
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  # p validity_test(attempt, grid)
  if validity_test(attempt, grid) && attempt != translation(attempt)
    time = end_time - start_time
    score = attempt.size * 3 - time * 0.1
    return { time: time, translation: translation(attempt), score: score, message: 'well done' }
  elsif validity_test(attempt, grid) && attempt.downcase == translation(attempt).downcase
    return { time: time, translation: nil, score: 0, message: "not an english word" }
  else
    return { time: time, translation: nil, score: 0, message: "not in the grid" }
  end
end
end
