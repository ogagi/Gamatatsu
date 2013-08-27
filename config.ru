require File.expand_path(File.dirname(__FILE__)) + "/app/app"

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'

set :environment, :development
set :run, false
set :raise_errors, true

run App.new
