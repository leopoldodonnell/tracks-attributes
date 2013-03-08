# @author Leo O'Donnell
require 'tracks_attributes/attr_info'
##
# A Module that can be used to extend ActiveRecord or Plain Old Ruby Objects
# with the ability to track all attributes. It also simplifies streaming to and
# from JSON or XML since it will automatically consider all attributes in the
# conversion.
#
# This module can also be used as building block for other classes that need to
# be dynamically aware of their attributes.
#
# Instance re-hydration from a Hash/JSON/XML may be simple, or may need more complex handling.
#
# In the case of simple re-hydration, attributes are simply assigned their values.
#
# When instances have more complex instance variables that need to be made available
# at run time when re-hydrating, a Class can be specified in the calls to <tt><attr_xxx/tt>
# with the key <tt>:klass</tt>. During the call to <tt>:attributes=</tt>, the Hash's value
# is used to consctruct an instance of <tt>klass</tt> if it supplies a <tt>klass::create</tt>
# class method. If the attribute is an array, the array will be mapped from instances of
# <tt>Hash</tt> to instances of <tt>klass</tt>
#
# *Example:*
#
#     class NestedClass
#       include TracksAttributes
#       tracks_attributes
#       
#       attr_accessor :one, :two
#       
#       def self.create(attributes = {})
#         # code to create an instance of NestedClass
#       end
#     end
#        
#     class TrackedClass < ActiveRecord::Base
#       tracks_attributes
#      
#       attr_accessible  :foo 
#       attr_accessor    :nested, :klass => NestedClass
#     end
#
# This example shows an <tt>ActiveRecord::Base</tt> class that has a plain old Ruby Object
# nested inside that needs to be streamed to and from JSON. It includes the module <tt>TracksAttribues</tt>
# and implements a <tt>:create</tt> class method.
#
# This example could be further simplified by using the <tt>TracksAttributes::Base</tt> class. <tt>NestedClass</tt>
# would be re-cast as:
#
#     class NestedClass < TracksAttributes::Base
#       attr_accessor :one, :two
#     end
#
module TracksAttributes
  extend ActiveSupport::Concern
  
  module ClassMethods
    ##
    # Call this class method to begin tracking attributes on a class.
    #
    # @param [Hash] options With values:
    #   * :validates => true will enable attribute validation
    #
    # Note:
    #   Classes that include TracksAttributes will not be extended unless
    #   until this method is called.
    #
    # @see TracksAttributesInternal TracksAttributesInternal for full method list
    def tracks_attributes(options={})
      include TracksAttributesInternal
      enable_validations if options[:validates]
      self
    end
  end
  
  module TracksAttributesInternal
    extend ActiveSupport::Concern

    included do
      @tracked_attrs ||= {}
    end

    module ClassMethods
      
      # Override attr_accessor to track accessors for an TracksAttributes.
      # If the last argument may be a <tt>Hash</tt> of options where the
      # options may be:
      #
      # * klass - the Class of the attribute to create when re-hydrating
      #           the instance from a Hash/JSON/XML
      #
      def attr_accessor(*vars)
        super *(add_tracked_attrs(true, true, *vars))
      end

      # Override attr_reader to track accessors for an TracksAttributes.
      # If the last argument may be a <tt>Hash</tt> of options where the
      # options may be:
      #
      # * klass - the Class of the attribute to create when re-hydrating
      #           the instance from a Hash/JSON/XML
      #
      def attr_reader(*vars)
        super *(add_tracked_attrs(true, false, *vars))
      end

      # Override attr_writer to track accessors for an TracksAttributes.
      # If the last argument may be a <tt>Hash</tt> of options where the
      # options may be:
      #
      # * klass - the Class of the attribute to create when re-hydrating
      #           the instance from a Hash/JSON/XML
      #
      def attr_writer(*vars)
        # avoid tracking attributes that are added by the class_attribute
        # as these are class attributes and not instance attributes.
        tracked_vars = vars.reject {|var| respond_to? var }
        add_tracked_attrs(false, true, *tracked_vars)
        vars.extract_options!
        super
      end

      # return an array of all of the attributes that are not in active record
      def accessors
        @tracked_attrs.keys ||= []
      end

      # return the attribute information for the provided attribute
      def attr_info_for(attribute_name)
        @tracked_attrs[attribute_name.to_sym]
      end
      
      # turn on ActiveModel:Validation validations
      def enable_validations
        include ActiveModel::Validations unless respond_to?(:_validators)
      end
      
      private
        def add_tracked_attrs(is_readable, is_writeable, *vars) #:nodoc:
          attr_params = vars.extract_options!        
          klass = attr_params[:klass]
          vars.each do |var| 
            @tracked_attrs[var] = AttrInfo.new(
             :name  => var, 
             :klass => klass, 
             :is_readable   => is_readable,
             :is_writeable  => is_writeable
            )
          end
          vars
        end
    end

    # Return the array of accessor symbols for instances of this
    # class.
    def accessors
      self.class.accessors
    end    

    # Return a hash all of the accessor symbols and their values
    def all_attributes
      the_attrs = Hash[accessors.collect {|v| [v, send(v.to_s)] if respond_to? "#{v}".to_sym}]
      (respond_to?(:attributes) && attributes.merge(the_attrs)) || the_attrs
    end

    # Set all attributes with hash of symbols and their values and returns instance
    def all_attributes=(hash = {})
      hash.each { |k, v| set_attribute(k, v) }
      self
    end

    # Convert an TracksAttributes instance to JSON by delegating conversion to Hash.to_json
    #
    # @param [Hash] options
    #   * Without any options, the returned JSON string will include all of the attributes.
    #   * :only => one, or an array of Hash Keys that define which keys to process
    #   * :except => one, or an array of Hash Keys that define which keys not to process
    #
    def to_json(options = nil)
      all_attributes.to_json(options)
    end

    # Returns an instance of TracksAttributes from a JSON string
    def from_json(json, include_root=false)
      hash = ActiveSupport::JSON.decode(json)
      hash = hash.values.first if include_root
      self.all_attributes = hash
    end

    # Convert an TracksAttributes instance to XML by delegating conversion to Hash.to_xml
    #
    # @param [Hash] options
    #   * Without any options, the returned XML string will include all of the attributes.
    #   * :only => one, or an array of Hash Keys that define which keys to process
    #   * :except => one, or an array of Hash Keys that define which keys not to process
    #
    # The :builder option uses key as the :root for the XML
    # result
    #
    def to_xml(options = nil)
      all_attributes.to_xml(options || {})
    end

    # Returns an instance of TracksAttributes from an XML string
    def from_xml(xml)
      hash = Hash.from_xml(xml).values.first
      self.all_attributes = hash
    end

    private
      def set_attribute(name, value) #:nodoc:
        return unless respond_to? "#{name}=".to_sym 
        
        attr_info = self.class.attr_info_for name
        klass     = attr_info && attr_info.klass
        
        if klass && klass.respond_to?(:create)
          value = value.kind_of?(Array)? set_array_values(value, klass) : klass.create(value)
        end
        
        send("#{name}=", value)
      end
      
      def set_array_values(array, klass) #:nodoc:
        array.map { |value| klass.create value }
      end
  end
end

require 'tracks_attributes/base'
require 'tracks_attributes/railtie'