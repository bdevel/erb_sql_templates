require 'erb'
require 'ostruct'

# Name template files as `some_query.sql.erb`  -- Use <%= h my_var %> - h helper will sanitize
# est = ErbSqlTemplates.new(Rails.root.to_s + '/db/sql', ActiveRecord::Base.connection)
# est.execute(:some_sql, :my_var => 'Foo!')
# sql = est.render(:some_sql, :my_var => 'Foo!')

class ErbSqlTemplates
  
  def initialize(dir, connection)
    @directory  = dir
    @connection = connection
  end
  
  def execute(name, **data)
    sql = render(name, data)
    @connection.execute(sql)
  end
  
  # Returns built sql
  def render(template_name, **data)
    scope      = TemplateScope.new(@connection, data)
    erb_string = load_template(template_name)
    renderer   = ERB.new(erb_string, 0, '>') # thread level zero, and '>' means no new lines for <%= %>
    return renderer.result(scope.get_binding)
  end
  
  # Returns string of the filename
  def locate_template(name)
    results = Dir.glob(@directory + "/#{name}.{sql.erb,erb}")
    if results.length > 1
      raise Exception.new("Too many templates have the name '#{name}'. ")
    elsif results.length == 0
      raise Exception.new("Cannot find template '#{name}.erb' or '#{name}.sql.erb' in the directory '#{@directory}'.")
    else
      return results.first
    end
  end
  
  # returns string of the template
  def load_template(name)
    filename = locate_template(name)
    File.read(filename)
  end
  
  
  class TemplateScope < OpenStruct
    def initialize(connection, hash)
      @connection = connection
      super hash
    end
    
    # helper for sanitizing sql inputs
    def h(value)
      return @connection.quote(value)
    end
    
    # Expose private binding() method.
    def get_binding
      binding()
    end
    
    # Raise exeption if you try to use a property that does not exist.
    def method_missing(prop, *args)
      if prop.to_s.include?('=') || (@table != nil && (@table.has_key?(prop) || self.respond_to?(prop))  )
        super
      else
        raise NoMethodError, "No property `#{prop}` set for this SQL.", caller(1)
      end
    end
    
  end
  
end


