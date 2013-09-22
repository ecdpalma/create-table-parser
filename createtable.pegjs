{
 tables = [];
 table = {};
 table.columns = [];
}

start = create_stmt*

create_stmt = "CREATE TABLE" ws+ this_table_name ws* lparen ws* table_element ws* (comma ws* table_element)* ws* (comma? ws* table_constraint)* ws* rparen ws* ";" (ws*)? {
  tables.push(table)
  table = {}
  table.columns = []
}

table_constraint = tab_const_unique / tab_const_fk;

tab_const_unique = "UNIQUE" ws* lparen ws* column_name ws* (comma ws* column_name)* rparen;

tab_const_fk = "CONSTRAINT" ws+ column_name ws+ "FOREIGN KEY" ws* lparen ws* column_name ws* rparen ws* fk_clause

fk_clause = "REFERENCES" ws+ table_name ws* (lparen ws* column_name (comma ws* column_name)* ws* rparen)? (ws+ fk_clause_action)*

fk_clause_action = "ON" ws+ ("DELETE" / "UPDATE" / "INSERT") ws+ ("NO ACTION" / "SET DEFAULT" / "SET NULL" / "CASCADE" / "RESTRICT")

table_element = col_name:column_name ws+ col_type:column_type  (ws+ column_constraint)* {
    table.columns.push({name: col_name, type: col_type});
}

this_table_name = table_name:ident+ {
   table.table_name = table_name.join("")
}

table_name = table_name:ident+ {
   return table_name.join("")
}

column_name = col_name:ident+ {
   return col_name.join("")
}

column_type = col_def:[a-zA-Z]+ {
   return col_def.join("")
}

column_constraint = constr_pk
  / constr_default
  / constr_not_null
  / constr_null


ident = [A-Za-z_]

constr_pk = "PRIMARY KEY" ws+ ("ASC" ws+ / "DESC" ws+)? ("AUTOINCREMENT")?

constr_not_null = "NOT NULL"
constr_null = "NULL"
constr_unique = "UNIQUE"
constr_default = "DEFAULT" ws+ (signed_default_number / literal_value)

signed_default_number = ("+"/"-")? (integer / float)
literal_value
  = integer  / float / string
  / "NULL"
  / "CURRENT_TIME"
  / "CURRENT_DATE"
  / "CURRENT_TIMESTAMP"
  / bool

bool = "TRUE" / "FALSE"

quote_single = "'"
quote_double = "\""
string_single = (quote_single string_core quote_single)
string_double = (quote_double string_core quote_double)
string_core = [ a-zA-Z0-9]
string = (string_single / string_double)


lparen = "("
rparen = ")"

ws = [ \n\t] { }
rest = [ a-zA-z\n();]+
comma = ","

integer = [0-9]+
float = [0-9]+ "." [0-9]+