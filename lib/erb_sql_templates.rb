require 'erb'
require 'ostruct'

# Name template files as `some_query.sql.erb`  -- Use <%= h my_var %> - h helper will sanitize
# est = ErbSqlTemplates.new(Rails.root.to_s + '/db/sql', ActiveRecord::Base.connection)
# est.execute(:some_sql, :my_var => 'Foo!')
# sql = est.render(:some_sql, :my_var => 'Foo!')

class ErbSqlTemplates
  attr_reader :connection
  
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
    scope      = TemplateScope.new(self, data)
    erb_string = load_template(template_name)
    renderer   = ERB.new(erb_string, 0, '>') # thread level zero, and '>' means no new lines for <%= %>
    return renderer.result(scope.get_binding)
  end
  
  # Returns string of the filename
  def locate_template(name)
    results = Dir.glob(@directory + "/#{name}.{erb.sql,sql.erb}")
    if results.length > 1
      raise Exception.new("Too many templates have the name '#{name}'. ")
    elsif results.length == 0
      raise Exception.new("Cannot find template '#{name}.erb.sql' in the directory '#{@directory}'.")
    else
      # Check if they are using old file extensions. Only do it once though.
      if @@did_send_deprecation_notice != true && results.first.match(/\.sql\.erb$/)
        @@did_send_deprecation_notice = true
        puts "Deprecation Notice: .sql.erb extensions for ERB SQL templates has been deprecated in favor of .erb.sql extensions."
      end
      
      return results.first
    end
  end
  
  # returns string of the template
  def load_template(name)
    filename = locate_template(name)
    File.read(filename)
  end
  
  
  class TemplateScope < OpenStruct
    def initialize(builder, hash)
      @builder = builder
      super hash
    end
    
    def render(template_name, **args)
      return @builder.render(template_name, **args)
    end
    
    # helper for sanitizing sql inputs
    def h(value)
      return @builder.connection.quote(value)
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
  
  @@did_send_deprecation_notice=false
end


