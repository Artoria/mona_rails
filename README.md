mona_rails
==========

MONo file App in Rails



try
```ruby
require './mona_rails.rb'

Rails.new :app
Dir.chdir 'app'
FileLines['gemfile'][0, 1] = 'source "https://ruby.taobao.org"'
Bundle.install



person = Entity.new 'person'
person.model name: 'string', age: 'integer'
person.get 'say' do
  '<% @person = Person.find(1) %>
   <%= @person.name %><BR/>
   <%= @person.age %>
  '
end


person.get 'insert' do
  '<%
     p = Person.new
	 p.id = 1
	 p.name = "Hello"
     p.age = 2
	 p.save
  %>
  done'
end
Rails.server
```
