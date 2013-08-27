require 'data_mapper'
require 'dm-core'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'dm-timestamps'

class Movie
  include DataMapper::Resource

  has n, :attachments

  property :id,         Serial
  property :created_at, DateTime
  property :sinopsis,   Text
  property :genre,      String
  property :title,      String
  property :updated_at, DateTime

end
