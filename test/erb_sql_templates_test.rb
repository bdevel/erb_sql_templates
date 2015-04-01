require_relative '../lib/erb_sql_templates'
require_relative 'connection_stub'
require "minitest/autorun"

describe ErbSqlTemplates do
  
  before :each do
    @connection = ConnectionStub.new
    @builder    = ErbSqlTemplates.new('test/templates', @connection)
  end
  
  it "should build sql" do
    assert_match /UPDATE my_table/, rendered_sql
    assert_match /SET\s+my_column = 'bad''value'/, rendered_sql
  end
  
  it "should render partials" do
    partial_sql = 'crazyName = CONCAT(name, "Foo!", lastName)'
    assert rendered_sql.include?(partial_sql), "Did not render partial: " + partial_sql
  end
  
  it "should execute sql" do
    @builder.execute(:complex_update,
                     table_name: 'my_table',
                     assignment_column: 'my_column',
                     value: "bad'value")
    assert_equal 1, @connection.executions.size
  end
  
  it "should give warning about .sql.erb extensions" do
    # Stub the puts method.
    def @builder.puts(s)
      @puts_log ||= []
      @puts_log << s
    end
    def @builder.puts_log
      @puts_log
    end
    
    sql = @builder.render(:deprecated)
    sql = @builder.render(:deprecated)
    
    assert @builder.puts_log.length != 0, "Did not warn user of deprecation."
    assert @builder.puts_log.length < 2, "Warned user more than once."
    assert_match /\.sql\.erb/i, @builder.puts_log.first
  end
  
  #----------------------------------------------------------------------------
  
  def rendered_sql
    @builder.render(:complex_update,
                    table_name: 'my_table',
                    assignment_column: 'my_column',
                    value: "bad'value")    
  end
  
end
