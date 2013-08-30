require 'sinatra'
require './models.rb'
require 'data_mapper'

before do
  headers 'Content-type' => 'text/html; charset=utf-8'
end

set :haml, :format => :html5

get "/" do
  @title = 'Gamatatsu'
  haml :index
end

post '/movie/create' do
  movie            = Movie.new(params[:movie])
  image_attachment = movie.attachments.new
  movie_attachment = movie.attachments.new
  image_attachment.handle_upload(params['image-file'])
  movie_attachment.handle_upload(params['movie-file'])
  if movie.save
    @message = 'Movie was saved.'
  else
    @message = 'Movie was not saved.'
  end
  haml :create
end

get '/movie/new' do
  @title = 'Upload Movie'
  haml :new
end

get '/movie/list' do
  @title = 'Available Movies'
  @movies = Movie.all(:order => [:title.desc])
  haml :list
end

get '/movie/show/:id' do
  @movie = Movie.get(params[:id])
  @title = @movie.title
  if @movie
    haml :show
  else
    redirect '/movie/list'
  end
end

get '/movie/watch/:id' do
  movie = Movie.get(params[:id])
  if movie
    @movies = {}
    movie.attachments.each do |attachment|
      supported_mime_type = $config.supported_mime_types.select { |type| type['extension'] == attachment.extension }.first
      if supported_mime_type['type'] === 'movie'
        @movies[attachment.id] = { :path => File.join($config.file_properties.movie.link_path['public'.length..-1], attachment.filename) }
      end
    end
    if @movies.empty?
      redirect "/movie/show/#{movie.id}"
    else
      @title = "Watch #{movie.title}"
      haml :watch
    end
  else
    redirect '/movie/list'
  end
end
