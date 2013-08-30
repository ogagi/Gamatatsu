require 'data_mapper'
require 'dm-core'
require 'dm-migrations'
require 'dm-sqlite-adapter'
require 'dm-timestamps'
require 'ostruct'

class Hash
  def self.to_ostructs(obj, memo={})
    return obj unless obj.is_a? Hash
    os = memo[obj] = OpenStruct.new
    obj.each { |k,v| os.send("#{k}=", memo[v] || to_ostructs(v, memo)) }
    os
  end
end

$config = Hash.to_ostructs(YAML.load_file(File.join(Dir.pwd,'config', 'config.yml')))

DataMapper.setup(:default, File.join('sqlite3://', Dir.pwd, '/db/', 'development.db'))

class Movie
  include DataMapper::Resource

  has n, :attachments

  property :id,             Serial
  property :created_at,     DateTime
  property :sinopsys,       Text
  property :genre,          String
  property :lenght,         Integer
  property :title,          String
  property :original_title, String
  property :updated_at,     DateTime
end

class Attachment
  include DataMapper::Resource

  belongs_to :movie

  property :id,              Serial
  property :created_at,      DateTime
  property :extension,       String
  property :filename,        String
  property :mime_type,       String
  property :path,            Text
  property :size,            Integer
  property :updated_at,      DateTime

  def import(file)
    self.extension = File.extname(file[:filename]).sub(/^\./, '').downcase
    supported_mime_type = $config.supported_mime_types.select { |type| type['extension'] == self.extension }.first
    return false unless supported_mime_type

    self.filename = file[:filename]
    self.mime_type = file[:type]
    self.path = File.join(Dir.pwd,
                          $config.file_properties.send(supported_mime_type['type']).absolute_path,
                          file[:filename])
    self.size = File.size(file[:tempfile])
    File.open(path, 'wb') do |f|
      f.write(file[:tempfile].read)
    end
    FileUtils.symlink(self.path, File.join($config.file_properties.send(supported_mime_type['type']).link_path, file[:filename]))
  end
end

configure :development do
  DataMapper.finalize
  DataMapper.auto_upgrade!
end
