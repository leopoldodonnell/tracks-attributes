# @author Leo O'Donnell

##
# A Module that can be used to extend ActiveRecord or Plain Old Ruby Objects
# with the ability to track all attributes. It also simplifies streaming to and
# from JSON or XML since it will automatically consider all attributes in the
# conversion.
#
# This module can also be used as building block for other classes that need to
# be dynamically aware of their attributes.
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
      include ActiveModel::Validations if options[:validates]
      self
    end
  end
  
  module TracksAttributesInternal
    extend ActiveSupport::Concern

    included do
      class_attribute :tracked_attrs      
      self.tracked_attrs ||= []
    end

    module ClassMethods
      # override attr_accessor to track accessors for an TracksAttributes
      def attr_accessor(*vars)
        tracked_attrs.concat vars if tracked_attrs
        super
      end

      # override attr_reader to track accessors for an TracksAttributes
      def attr_reader(*vars)
        tracked_attrs.concat vars if tracked_attrs
        super
      end

      # override attr_writer to track accessors for an TracksAttributes
      def attr_writer(*vars)
        tracked_attrs.concat vars if tracked_attrs
        super
      end

      # return an array of all of the attributes that are not in active record
      def accessors
        self.tracked_attrs ||= []
      end

    end

    # Return the array of accessor symbols for instances of this
    # class.
    def accessors
      self.class.accessors
    end    

    # Return a hash all of the accessor symbols and their values
    def all_attributes
      attributes.merge Hash[accessors.collect {|v| [v, send(v.to_s)] if respond_to? "#{v}".to_sym}]
    end

    # Set all attributes with hash of symbols and their values and returns instance
    def all_attributes=(hash = {})
      hash.each {|k, v| send("#{k.to_s}=", v) if respond_to? "#{k.to_s}=".to_sym}
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

  end
end

require 'tracks_attributes/railtie'
