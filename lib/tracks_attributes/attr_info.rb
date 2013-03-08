module TracksAttributes
  ##
  # Holds the information needed by a class including TracksAttributes
  # in order to track information that can be effectively used to
  # re-hydrate instances from JSON or XML
  class AttrInfo
    attr_accessor :name, :klass, :is_readable, :is_writeable
    
    ##
    # Props
    #   * :name - the attribute name
    #   * :kass - the attribute class
    #   * :is_readable - true if the attribute is readable
    #   * :is_writeable - true if the attribute is writeable
    #
    def initialize(props = {})
      self.name   = props[:name]
      self.klass  = props[:klass]
      self.is_readable   = props[:is_readable] || true
      self.is_writeable  = props[:is_writeable] || true
    end
  end  
end
