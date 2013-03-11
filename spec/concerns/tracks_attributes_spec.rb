require File.expand_path('../../spec_helper', __FILE__)
require 'tracks_attributes'

describe "TracksAttributesSpec" do
  before(:all) do
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS tracks_active_records")
    ActiveRecord::Base.connection.create_table(:tracks_active_records) do |t|
        t.integer :foo
        t.string  :bar
    end

    class TracksActiveRecord < ActiveRecord::Base
      tracks_attributes
      attr_accessible :foo
      attr_readonly   :bar
      attr_accessor   :baz
    end
    
  end
  
  after(:all) do
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS tracks_active_records")
  end
  
  it "is mixed into an ActiveRecord::Base class" do
    ActiveRecord::Base.should respond_to :tracks_attributes
  end
  
  it "only adds methods and tracks attributes afer tracks_attributes is called on the class" do
    class UntrackedActiveRecord < ActiveRecord::Base
      self.table_name = "tracks_active_records"
    end
    UntrackedActiveRecord.should_not respond_to :accessors
    UntrackedActiveRecord.tracks_attributes
    UntrackedActiveRecord.should respond_to :accessors
  end
  

  it "does not track class attributes like those added by class_attributes" do
    TracksActiveRecord.class_attribute :classy_attribute
    
    TracksActiveRecord.should respond_to :classy_attribute
    TracksActiveRecord.new.should respond_to :classy_attribute
    TracksActiveRecord.accessors.index(:classy_attribute).should be nil
  end
    
  it "provides validators for non active_record attributes when specified with :validates => true" do
    class ValidatesAttributes
      include TracksAttributes
      tracks_attributes :validates => true

      attr_accessor :content
    end
    ValidatesAttributes.should respond_to :validates_length_of

  end
  
  it "does not provide validators for non active_record attributes when :validates => false" do
    class DoesNotValidateAttributes
      include TracksAttributes
      tracks_attributes :validates => false

      attr_accessor :content
    end
    DoesNotValidateAttributes.should_not respond_to :validates_length_of
  end
  
  it "tracks all attr_accessible attributes" do
    class TrackerAll
      include TracksAttributes
      tracks_attributes
      attr_accessor :one
      attr_accessor :two, :three
    end
      
    t = TrackerAll.new
    t.accessors.length.should == 3
    t.accessors.each { |accessor|
      t.should respond_to accessor.to_sym
      t.should respond_to "#{accessor}=".to_sym
    }
    # make sure that the assignment operator responds
    # with the set value and sets the value
    (t.one = 5).should == t.one
    t.one.should == 5
  end

  it "tracks all attr_reader attributes" do
    class TrackerReader
      include TracksAttributes 
      tracks_attributes
      attr_reader :one
      attr_reader :two, :three
      
      def set_one v
        @one = v
      end
    end
    t = TrackerReader.new
    t.accessors.length.should == 3
    t.accessors.each { |accessor|
      t.should respond_to accessor.to_sym
      t.should_not respond_to "#{accessor}=".to_sym
    }
    t.set_one 5
    t.one.should == 5      
  end

  it "tracks all attr_writer attributes" do
    class TrackerWriter
      include TracksAttributes 
      tracks_attributes
      attr_writer :one
      attr_writer :two, :three
      
      def get_one
        @one
      end
    end
    t = TrackerWriter.new
    t.accessors.length.should == 3
    t.accessors.each { |accessor|
      t.should_not respond_to accessor.to_sym
      t.should respond_to "#{accessor}=".to_sym
    }
    t.one = 5
    t.get_one.should == 5      
  end
  
  it "tracks ActiveRecord Attributes" do
    t = TracksActiveRecord.new
    t.accessors.length.should == 1
    t.all_attributes.length.should == 4 # don't forget about the id
    t.attributes.length.should == 3
  end

  it "can convert a class instance to json with all attributes" do
    t = TracksActiveRecord.new :foo => 1
    t.baz = 'BAZ'
    parsed_json = JSON.parse t.to_json
    parsed_json['baz'].should == 'BAZ'
    parsed_json['foo'].should == 1
    parsed_json.has_key?('id').should be true
    
    parsed_json = JSON.parse t.to_json(:except => 'id')
    parsed_json.has_key?('id').should be false
  end

  it "can convert a json string into a class instance with all attributes" do
    t = TracksActiveRecord.new :foo => 1
    t.baz = 'BAZ'
    
    v = TracksActiveRecord.new
    v.from_json t.to_json(:except => :id)
    v.baz.should == 'BAZ'
    v.foo.should == 1
  end
  
  it "an convert a class instance to xml with all attributes" do
    t = TracksActiveRecord.new :foo => 1
    t.baz = 'BAZ'

    xml_string = t.to_xml
    parsed_xml = Hash.from_xml(xml_string).values.first
    parsed_xml['baz'].should == 'BAZ'
    parsed_xml['foo'].should == 1
    parsed_xml.has_key?('id').should be true
    
    parsed_xml = Hash.from_xml t.to_xml(:except => :id)
    parsed_xml.has_key?('id').should be false
  end
  
  it "can convert an xml string into a class instance with all attributes" do
    t = TracksActiveRecord.new :foo => 1
    t.baz = 'BAZ'
    
    v = TracksActiveRecord.new
    v.from_xml t.to_xml(:except => :id)
    v.baz.should == 'BAZ'
    v.foo.should == 1
  end
 
  it "should not track class attributes, but they should still work" do
    class Tracker
      include TracksAttributes
      tracks_attributes
      class_attribute :classy
      attr_accessor :one
    end
      
    t = Tracker.new
    t.accessors.length.should == 1
    t.respond_to?(:classy).should be true
  end
  
  it "should correctly re-hydrate an object instance if member variable types are provided" do
    class NestedClass < TracksAttributes::Base
      attr_accessor :one
      attr_accessor :two
    end
    
    class TrackedClass
      include TracksAttributes
      tracks_attributes
      
      attr_accessor :one 
      attr_accessor :nested, :klass => NestedClass
    end
    
    nested = NestedClass.create(:one => 1, :two => 2)
    
    tracked = TrackedClass.new
    tracked.one = 'one'
    tracked.nested = nested

    # tracked = TrackedClass.create(:one => 'one', :nested => nested)
    tracked_json = tracked.to_json
    re_hydrated = TrackedClass.new
    re_hydrated.from_json(tracked_json)
    
    re_hydrated.one.should == 'one'
    re_hydrated.nested.class.should == NestedClass
    re_hydrated.nested.one.should == 1
    re_hydrated.nested.two.should == 2
  end

  it "should correctly re-hydrate an object instance with arrays where member variable types are provided" do
    class NestedClass < TracksAttributes::Base
      attr_accessor :one
    end
    
    class TrackedClass
      include TracksAttributes
      tracks_attributes
      
      attr_accessor :nested, :klass => NestedClass
    end
    
    nested      = NestedClass.new(:one => 1)
    nested_too  = NestedClass.new(:one => 11)

    tracked = TrackedClass.new
    tracked.nested = [nested, nested_too]
    
    tracked_json = tracked.to_json
    re_hydrated = TrackedClass.new
    re_hydrated.from_json(tracked_json)
    
    re_hydrated.nested[0].class.should == NestedClass
    re_hydrated.nested[0].one.should == 1
    re_hydrated.nested[1].one.should == 11
  end
  
  describe "TracksAttributesBaseSpec" do
    it "Should implement tracks_attributes" do
      class AttributeTracker < TracksAttributes::Base
      end
      
      AttributeTracker.should respond_to :tracks_attributes
    end
    
    it "Should provide validators" do
      class AttributeTracker < TracksAttributes::Base
      end
      
      AttributeTracker.should respond_to :validates
    end
    
    it "Should track all attributes when derived" do
      class BaseNestedClass < TracksAttributes::Base
        attr_accessor :one
      end

      class NestedClass < TracksAttributes::Base
        attr_accessor :two
      end

      NestedClass.accessors.include?(:one).should be true
      NestedClass.accessors.include?(:two).should be true
    end
    
    it "Should allow programtic creation from already hydrated variables" do
      class NestedClass < TracksAttributes::Base
        attr_accessor :one
        attr_accessor :two
      end

      class ContainingClass  < TracksAttributes::Base
        attr_accessor :one 
        attr_accessor :nested, :klass => NestedClass
      end

      container = ContainingClass.create(:one => 'one', :nested => NestedClass.create(:one => 1, :two => 2))
      container.one.should == 'one'
      container.nested.one.should == 1
    end
        
  end
end
