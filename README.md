
[![Build Status](https://travis-ci.org/leopoldodonnell/tracks-attributes.png?branch=master)](https://travis-ci.org/leopoldodonnell/tracks-attributes)
[![Dependency Status](https://gemnasium.com/leopoldodonnell/tracks-attributes.png)](https://gemnasium.com/leopoldodonnell/tracks-attributes)
[![Code Climate](https://codeclimate.com/github/leopoldodonnell/tracks-attributes.png)](https://codeclimate.com/github/leopoldodonnell/tracks-attributes)
# TracksAttributes

TracksAttributes adds the ability to track ActiveRecord and Object level attributes.

This module extends ActiveRecord::Base with the *tracks_attributes* class method. Once this has been called
the class is extended with the ability to track attributes through *attr_accessor*, *attr_reader*, and *attr_writer*.
Plain old Ruby classes may also use *TracksAttributes* by including it as a module first.

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

## Add Validations To Non Active Record Attributes

To add ActiveModel::Validations to your class just initialize your class with *tracks_attributes* as

```ruby
  tracks_attributes :validates => true
```  
## Installation

Add the following to your Gemfile

    gem 'tracks-attributes', :git => "git://github.com/leopoldodonnell/tracks-attributes"

Then call bundle to install it.

    > bundle

This project rocks and uses MIT-LICENSE.