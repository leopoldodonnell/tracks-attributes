
[![Build Status](https://travis-ci.org/leopoldodonnell/tracks-attributes.png?branch=master)](https://travis-ci.org/leopoldodonnell/tracks-attributes)
[![Dependency Status](https://gemnasium.com/leopoldodonnell/tracks-attributes.png)](https://gemnasium.com/leopoldodonnell/tracks-attributes)
[![Code Climate](https://codeclimate.com/github/leopoldodonnell/tracks-attributes.png)](https://codeclimate.com/github/leopoldodonnell/tracks-attributes)
[![Gem Version](https://fury-badge.herokuapp.com/rb/tracks-attributes.png)](http://badge.fury.io/rb/tracks-attributes)

# TracksAttributes

TracksAttributes adds the ability to track ActiveRecord *and* Object level attributes. Beginning at version 1.1.0, it is
possible to re-hydrate complex object structures that contain *Plain Old Ruby Objects*, or arrays of *POROs*.

Sometimes you just need to know what your accessors are at runtime, like when you're writing a controller that
needs to return JSON or XML. This module extends ActiveRecord::Base with the *tracks_attributes* class method. Once this has 
been called the class is extended with the ability to track attributes through *attr_accessor*, *attr_reader*, and *attr_writer*.
*Plain Old Ruby* classes may also use *TracksAttributes* by including it as a module first.

*Note:* The necessity for this gem is born out of the clash between ActiveRecord attribute handling and PORO attributes. Using
Object::instance_variables just doesn't return the correct list for marshaling data effectively, nor produce values for computed
attributes.

## Enhanced JSON and XML processing

Beyond the ability to track your attributes, this gem simplifies your use of converting your objects to an from JSON or XML.
Once a class has been extended, it can convert to and from JSON or XML without having to explicitly include attributes.

Example:

```ruby
class Person < ActiveRecordBase
  tracks_attributes

  attr_accessible :name, :email
  attr_accessor :favorite_food
end

fred = Person.find_by_name("Fred")
fred.favorite_food = 'Brontosaurus Burgers'

fred_json = fred.to_json
puts fred_json
# => {"id":1,"name":"Fred","email":"fred@bedrock.com","favorite_food":"Brontosaurus Burgers"}

fred2 = Person.new
fred2.from_json(fred_json)
puts "#{fred2.name} loves #{fred2.favorite_food}"
# => Fred loves Brontosaurus Burgers
```

Both the JSON and XML take the same options as their Hash and ActiveRecord counterparts so you can still
use *:only* and *:includes* in your code as needed.

### Re-hydrating Complex Ruby Objects

Classes that have simple types, like <tt>Fixnum</tt> or <tt>String</tt>, can be handled by simply invoking
<tt>:tracks_attributes</tt> within the class definition. More complex objects require additional information
to converted from a <tt>Hash</tt> to the correct type of Object. This is done by providing the class in the 
calls to <tt>attr_accessor</tt>, <tt>attr_reader</tt> and <tt>attr_writer</tt>.

Specify the class of an attribute by providing the option, <tt>:klass</tt>, with the target class as the value.

Example:

```ruby
  attr_accessor :my_poro_var, :klass => MyPoroClass
```

The target class must then provide  class method, <tt>:create</tt>, taking a <tt>Hash</tt> of attributes to
construct the Object instance.

Here is example from <tt>TracksAttributes::Base</tt>

```ruby
  class Base
    include TracksAttributes
    tracks_attributes
    
    def self.create(attributes = {}, options = {})
      # implentation
    end
    
    # the rest of the class here...
  end
```

## Add Validations To Non Active Record Attributes

To add ActiveModel::Validations to your class just initialize your class with *tracks_attributes* as

```ruby
  tracks_attributes :validates => true
```

## Use <tt>TracksAttributes::Base</tt> to simplify coding *POROs*

While developers can continue to roll their own *PORO* class, <tt>TracksAttributes::Base</tt> provides a
quick implementation that tracks attributes, provides validation and works with <tt>TracksAttributes</tt>
when re-hydrating. Simply inherit from <tt>TracksAttributes::Base</tt> and you are good to go.

Here's an example that shows how simple it is to define:

```ruby
class Photo < TracksAttributes::Base
  attr_accessor :title, :filename
end

class Person < ActiveRecord::Base
  tracks_attributes

  attr_accessible :name 
  attr_accessor   :photos, :klass => Photo
end
```

Once this has been coded up, it is possible to generate JSON/XML that stream the entire array of
<tt>PhotoLocation</tt>. More importantly, it is possible to fully re-hydrate a Person, including
the array of <tt>Photo</tt>. Re-hydration takes place when the <tt>Hash</tt> of attributes is set
on the Object instance.

Continuing...

```ruby
# Instance Creation
photos = [ 
  Photo.create(:title => 'Hadji and Me', :filename => 'images/hadji_and_me.png'),
  Photo.create(:title => 'Bandit', :filename => 'images/bandit.png')
]

johnny_quest        = Person.new(:name => 'Johnny Quest')
johnny_quest.photos = photos

# Generate the JSON
jq_json = johnny_quest.to_json

# => {"name":"Johnny Quest","photos":[{"title":"Hadji and Me","filename":"images/hadji_and_me.png"},{"title":"Bandit","filename":"images/bandit.png"}]}

# Later Re-hydrate the JSON
json_param = params[:person]
person = Person.new
person.from_json json_param

puts "Name = #{person.name}, 1st image title = #{person.photos[0].title}"
# => Johnny Quest, 1st image title = Hadji and Me

```

## Installation

Add the following to your Gemfile
    
    gem 'tracs-attributes

Or from the git repo for the bleeding edge (*feel free to star it :-)*)

    gem 'tracks-attributes', :git => "git://github.com/leopoldodonnell/tracks-attributes"

Then call bundle to install it.

    > bundle

## License

This project rocks and uses MIT-LICENSE. Copyright 2013 Leopold O'Donnell