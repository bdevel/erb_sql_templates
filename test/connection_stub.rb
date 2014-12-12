
class ConnectionStub
  attr_reader :executions
  
  def initialize
    @executions = []
  end
  
  def execute(sql)
    @executions << sql
  end
  
  def quote(value)
    return value if value.is_a?(Numeric)
    return "'" + value.gsub("'", "''") + "'"
  end
  
end

