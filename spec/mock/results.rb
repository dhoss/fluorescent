class Results
  attr_accessor :name, :title, :body, :id
  
  def initialize args 
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

end
