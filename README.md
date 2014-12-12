# ERB SQL Templates for Ruby

Use `erb_sql_templates` when you have large complex SQL queries that you do not want
embedded inside your Ruby. The gem allows for SQL to be stored in their own
directory and files and the queries can be customized with ERB.


### Example

Example SQL template file, `some_query.sql.erb`. Templates must have `.sql.erb` extension.
```sql
SELECT *
FROM <%= table_name %>
WHERE
  column = <%= h(my_var) %>
```

To use the template in Ruby, specify the template directory,
a database connection, and call `#execute` or `#render` with the template name.
Names arguments will be available inside the SQL template.

```ruby
template_dir = Rails.root.to_s + '/db/sql/templates'
sql_builder = ErbSqlTemplates.new(template_dir, ActiveRecord::Base.connection)

# Execute SQL directly
sql_builder.execute(:some_query, :my_var => 'Foo!', :table_name => 'my_table')

# Or have it return the SQL
sql = sql_builder.render(:some_query, :my_var => 'Foo!', :table_name => 'my_table')
```

### SQL Sanitizing
The library expects that the connection has a `#quote` method on it.
Inside your SQL template you can use the `h` helper to escape variables.
Example: `UPDATE users SET name = <%= h dirty_input %>`

