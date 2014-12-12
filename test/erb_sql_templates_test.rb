require_relative '../lib/erb_sql_templates'
require_relative 'connection_stub'
require "minitest/autorun"

describe ErbSqlTemplates do

  before :each do
    @connection = ConnectionStub.new
    @builder    = ErbSqlTemplates.new('test/templates', @connection)
  end
  
  it "should build sql" do
    sql = @builder.render(:complex_update,
                          table_name: 'my_table',
                          assignment_column: 'my_column',
                          value: "bad'value")
    assert_match /UPDATE my_table/, sql
    assert_match /SET my_column = 'bad''value'/, sql
  end
  
  it "should execute sql" do
    @builder.execute(:complex_update,
                     table_name: 'my_table',
                     assignment_column: 'my_column',
                     value: "bad'value")
    assert_equal 1, @connection.executions.size
  end
  
  it "should not allow access to connection" do
    assert_raises NoMethodError do
      @builder.render(:connection_access)
    end
  end
  
  
end
