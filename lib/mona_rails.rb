require 'shellwords'
require 'digest/sha1'

class Commands
  def initialize(str)
    @str = str
  end
  def self.system(*a)
    super Shellwords.shelljoin(a.map(&:to_s))
  end

  def system(*a)
    self.class.system @str, *a
  end 
  alias method_missing system
end

Rails  = Commands.new("rails")
Bundle = Commands.new("bundle")
Rake   = Commands.new("rake")
class FileLines 
  def self.[](*a)
    new *a
  end
  def initialize(filename)
    @filename = filename
  end
  def alternate(filename)
    x = IO.readlines(filename)
	ret = yield x
	open(filename, 'w') do |f| f.write x.join("\n") end
	ret
  end
  def []=(a, b, c)
    alternate @filename do |arr| arr[a,b] = c end
  end
  def [](a, b)
    alternate @filename do |arr| arr[a,b] end
  end
end

module Mona
  class << self
    def rb_append_line(file, line)
      x = File.read(file)
      digest = Digest::SHA1.hexdigest(line)
      return if x[digest]
      str = "\n#begin #{digest}\n#{line}\n#end #{digest}\n"
      open(file, 'a') do |f| f.write str end
    end
  end
end

module Routes
  class << self
    def get opt
      Mona.rb_append_line 'config/routes.rb', "Rails.application.routes.draw do get(#{opt.inspect}) end"
    end
  end
end

class Writer
  def initialize(file, writer = nil, &b)
    @file = file
    @writer = writer || b
  end
  def method_missing(sym, *a, &b)
    Mona.rb_append_line(@file, @writer.call(sym, b))
  end  
end

class Entity
  def initialize(name)
    @name = name
    Rails.generate :controller, @name
  end

  def model(opt)
    filename = "app/models/#{@name}.rb"
    Rails.generate :model, @name, *opt.map{|k, v| "#{k}:#{v}"}
    Rake.send "db:migrate"
  end

  def controller

    Writer.new "app/controllers/#{@name}_controller.rb" do |sym, b|
"class #{@name.capitalize}Controller < ApplicationController
   def #{sym}
     #{b.call}     
   end
 end
"  
    end
  end

  def render(opt)
    "render(#{opt.inspect})"
  end

  def get(method_name, route = nil)
    controller.send method_name do
       render inline: yield
    end
    Routes.get (route || "#{@name}/#{method_name}") => "#{@name}##{method_name}"
  end
end
