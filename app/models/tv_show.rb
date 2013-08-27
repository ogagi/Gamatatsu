require 'data-mapper'
require 'dm-core'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'dm-timestamps'

class TvShow
  include DataMapper::Resource

  has n :attachments

  property :id,         Serial
  property :created_at, DateTime
  property :sinopsis,   Text
  property :genre,      String
  property :title,      String
  property :seasons,    Integer
  property :updated_at, DateTime

end
