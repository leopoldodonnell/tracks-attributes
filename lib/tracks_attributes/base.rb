module TracksAttributes
  ##
  # TracksAttributes::Base is a convienience class that offers
  # the basic services available through the TracksAttribute module
  # for plain old ruby objects.
  #
  # * it tracks attributes
  # * it provides <tt>Base::create</tt> to enable re-hydration within the scope
  #   of a containing class that is being built from JSON or XML
  # * it includes <tt>ActiveModel::Validations</tt>
  # 
  class Base
    extend ClassMethods
    include ActiveModel::Validations
    tracks_attributes
    
    ##
    # The standard create class method needed by a class that implements
    # TracksAttributes during re-hydration.
    # 
    # @param [Hash] attributes is Hash with attributes as values to set
    # as instance variables.
    # @param [Hash] options to be passed onto the initialize method.
    #
    def self.create(attributes = {}, options = {})
      self.new attributes, options
    end

    ##
    # The default :initialize method needed by a class that implements
    # TracksAttributes during re-hydration.
    # 
    # @param [Hash] attributes is Hash with attributes as values to set
    # as instance variables.
    # @param [Hash] options to be passed onto the initialize method.
    #
    def initialize(attributes = {}, options = {})
      self.all_attributes = attributes
    end
  end
end
