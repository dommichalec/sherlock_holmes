require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'
require_relative 'helpers'

before do
  @table_of_contents = File.readlines('data/toc.txt')
end

get '/' do
  @title = 'The Adventures of Sherlock Holmes'
  @author = 'Sir Arthur Doyle'

  erb :home
end

get '/chapters/:number' do
  number = params[:number].to_i
  chapter_name = @table_of_contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get '/search' do
  if params[:query]
    # each result in this array will be:
    # [ chapter name, chapter index, paragraph index ]
    @results = @table_of_contents.each_with_index.each_with_object([]) do |(chapter, index), results|
      text = File.read("data/chp#{index + 1}.txt")
      paragraphs = text.split("\n\n")
      paragraphs.each_with_index do |paragraph, paragraph_index|
        if paragraph.include?(params[:query])
          results << [chapter, index, paragraph, paragraph_index]
        end
      end
    end
  end

  erb :search
end

not_found do
  redirect '/'
end
