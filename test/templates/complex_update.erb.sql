
-- Some comments can go here.

UPDATE <%= table_name %>
SET
  <%= assignment_column %> = <%= h value %>,
  crazyName = <%= render '_crazy_manipulation', column: 'name', other_column: 'lastName' %>;
