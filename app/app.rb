$global_path = File.expand_path(File.dirname(__FILE__))
$:.unshift $global_path

require 'sinatra/base'
require 'models/movie'
#require 'models/tv_show'
require 'models/attachment'

class App < Sinatra::Base

  configure do
    DataMapper.setup(:default, File.join('sqlite3://',$global_path,'..','db/', 'development.db'))
  end

  configure :development do
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  before do
    headers "Content-Type" => 'text/hmtl; charset=utf-8'
  end

  get '/' do
    @title = 'Gamatatsu'
    haml :index
  end

  post 'movie/create' do
    movie = Movie.new(params[:movie])
    image_attachment = movie.attachmnts.new
    image_attachment.handle_upload(params['image-file'])
    if movie.save
      @message = 'Movie added to Library'
    else
      @message = 'Movie was not saved'
    end
    haml :create
  end

  get 'movie/new' do
    @title = 'Add movie'
    haml :new
  end

  get 'movie/list' do
    @title = 'Movies'
    @movies = Movie.all(:order => [:title.desc])
    haml :list_movies
  end

  get 'movie/show/:id' do
    @movie = Movie.get(params[:id])
    @title = @movie.title
    if @movie
      haml :show
    else
      redirect 'movie/list'
    end
  end
end


