#Populate the module with the custom exceptions
module UsefullTable
  class CustomError < StandardError
    def initialize(*args)
        @options = args.extract_options!
        super
    end
      
    def message
      @options.merge!({:default => "Error : #{@options.inspect}"})
      #I18n.t("#{self.class.name.gsub(/::/,'.')}",  :default => "Error : #{@options.inspect}",  @options)
      I18n.t("#{self.class.name.gsub(/::/,'.')}", @options )
    end
  end 
  
  class MissingBlock < CustomError ; end
end
