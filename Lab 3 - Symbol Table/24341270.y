%{

#include "symbol_table.h"

#define YYSTYPE symbol_info*

extern FILE *yyin;
int yyparse(void);
int yylex(void);
extern YYSTYPE yylval;

// create your symbol table here.


// You can store the pointer to your symbol table in a global variable
// or you can create an object
symbol_table *st = new symbol_table(10);


int lines = 1;

ofstream outlog;

// you may declare other necessary variables here to store necessary info
// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.

string current_var_type;  // To store the type of variable being declared
vector<string> var_list;  // To store variable names for insertion into the symbol table
string func_name;         // To store the name of a function being defined
string return_type;       // To store the return type of a function
vector<string> func_param_types; // To store function parameter types
vector<string> func_param_names; // To store function parameter names


void yyerror(char *s)
{
	outlog<<"At line "<<lines<<" "<<s<<endl<<endl;

    // you may need to reinitialize variables if you find an error
	current_var_type = "";
	var_list.clear();
	func_name = "";
	return_type = "";
	func_param_types.clear();
	func_param_names.clear();

}

%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		outlog<<"At line no: "<<lines<<" start : program "<<endl<<endl;
		outlog<<"Symbol Table"<<endl<<endl;
		
		// Print your whole symbol table here

		st->print_all_scopes(outlog);
	}
	;

program : program unit
	{
		outlog<<"At line no: "<<lines<<" program : program unit "<<endl<<endl;
		outlog<<$1-> get_name()+"\n"+$2-> get_name()<<endl<<endl;
		
		$$ = new symbol_info($1-> get_name()+"\n"+$2-> get_name(),"program");
	}
	| unit
	{
		outlog<<"At line no: "<<lines<<" program : unit "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
		
		$$ = new symbol_info($1-> get_name(),"program");
	}
	;

unit : var_declaration
	 {
		outlog<<"At line no: "<<lines<<" unit : var_declaration "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
		
		$$ = new symbol_info($1-> get_name(),"unit");
	 }
     | func_definition
     {
		outlog<<"At line no: "<<lines<<" unit : func_definition "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
		
		$$ = new symbol_info($1-> get_name(),"unit");
	 }
     ;

ScopeStart: /* empty */
	{
		st->enter_scope();
    	outlog<<"New ScopeTable with ID "<< st->get_current_scope_id() <<" created"<<endl<<endl;
	}
	;

func_definition : type_specifier ID LPAREN parameter_list RPAREN ScopeStart compound_statement
	{
    outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl<<endl;
    outlog<<$1->get_name()<<" "<<$2->get_name()<<"("<<$4->get_name()<<")\n"<<$6->get_name()<<endl;


    symbol_info *func_info = new symbol_info($2->get_name(), "Function");
    func_info->set_data_type($1->get_name()); // Set the return type
    func_info->set_param_type(func_param_types); // Set parameter types
    func_info->set_no_of_parameters(func_param_types.size());
    st->insert(func_info);
    func_param_types.clear();

    
		}


		| type_specifier ID LPAREN RPAREN compound_statement
		{
			
			outlog<<"At line no: "<<lines<<" func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl<<endl;
			outlog<<$1-> get_name()<<" "<<$2-> get_name()<<"()\n"<<$5-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+" "+$2-> get_name()+"()\n"+$5-> get_name(),"func_def");	
			
			// The function definition is complete.
            // You can now insert necessary information about the function into the symbol table
            // However, note that the scope of the function and the scope of the compound statement are different.
			// Start new scope for the function body
            st->enter_scope();
			outlog<<"New ScopeTable with ID "<<st->get_current_scope_id()<<" created"<<endl;

            // Insert the function into the symbol table
            symbol_info *func_info = new symbol_info($2-> get_name(), "FUNCTION");
            func_info->set_data_type($1-> get_name()); 
            func_info->set_no_of_parameters(0); // No parameters
            st->insert(func_info);
		}
 		;

parameter_list : parameter_list COMMA type_specifier ID
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier ID "<<endl<<endl;
			outlog<<$1-> get_name()<<","<<$3-> get_name()<<" "<<$4-> get_name()<<endl<<endl;
					
			$$ = new symbol_info($1-> get_name()+","+$3-> get_name()+" "+$4-> get_name(),"param_list");

            // Store parameter types and names for function signature
            func_param_types.push_back($3-> get_name());
            func_param_names.push_back($4-> get_name());
		}
		| parameter_list COMMA type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : parameter_list COMMA type_specifier "<<endl<<endl;
			outlog<<$1-> get_name()<<","<<$3-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+","+$3-> get_name(),"param_list");

            // Store the parameter type
            func_param_types.push_back($3-> get_name());
		}
 		| type_specifier ID
 		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier ID "<<endl<<endl;
			outlog<<$1-> get_name()<<" "<<$2-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+" "+$2-> get_name(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
			// Store the parameter type
            func_param_types.push_back($1-> get_name());
            func_param_names.push_back($2-> get_name());
		}
		| type_specifier
		{
			outlog<<"At line no: "<<lines<<" parameter_list : type_specifier "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"param_list");
			
            // store the necessary information about the function parameters
            // They will be needed when you want to enter the function into the symbol table
			func_param_types.push_back($1-> get_name());
		}
 		;

compound_statement : LCURL statements RCURL
			{
    		outlog<<"At line no: "<<lines<<" compound_statement : LCURL statements RCURL "<<endl<<endl;
   			outlog<<"{\n"<<$2->get_name()<<"\n}"<<endl<<endl;

    		st->print_current_scope(outlog);
    		outlog<<"ScopeTable with ID "<<st->get_current_scope_id()<<" removed"<<endl;

    		st->exit_scope();
			}
 		    | LCURL RCURL
 		    { 
 		    	outlog<<"At line no: "<<lines<<" compound_statement : LCURL RCURL "<<endl<<endl;
				outlog<<"{\n}"<<endl<<endl;
				
				$$ = new symbol_info("{\n}","comp_stmnt");

 		    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
{
    outlog<<"At line no: "<<lines<<" var_declaration : type_specifier declaration_list SEMICOLON "<<endl<<endl;
    outlog<<$1-> get_name()<<" "<<$2-> get_name()<<";"<<endl<<endl;

    $$ = new symbol_info($1-> get_name()+" "+$2-> get_name()+";","var_dec");

    current_var_type = $1-> get_name();
    for (auto var : var_list) {
        symbol_info* sym = new symbol_info(var, "Variable");
        sym->set_data_type(current_var_type); // Set the variable type
        st->insert(sym);
    }
    var_list.clear();
}



declaration_list : declaration_list COMMA ID
		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID "<<endl<<endl;
 		  	outlog<<$1-> get_name()+","<<$3-> get_name()<<endl<<endl;

            $$ = new symbol_info($1-> get_name()+","+$3-> get_name(),"dec_list");

            // Store the variable name for later insertion into the symbol table
            symbol_info* sym = new symbol_info($3->get_name(), "Array");
    		sym->set_data_type(current_var_type); // Set the data type of the array
    		st->insert(sym);  // Insert the array into the symbol table
 		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
 		  	outlog<<$1-> get_name()+","<<$3-> get_name()<<"["<<$5-> get_name()<<"]"<<endl<<endl;

            $$ = new symbol_info($1-> get_name()+","+$3-> get_name()+"["+$5-> get_name()+"]","dec_list");

            // Store the array name and size for later insertion into the symbol table
            symbol_info* sym = new symbol_info($3-> get_name(), "ARRAY");
            sym->set_array_size(stoi($5-> get_name())); // Store array size
            var_list.push_back($3-> get_name()); // Add to the list for later insertion
 		  }
 		  | ID
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;

            $$ = new symbol_info($1-> get_name(),"dec_list");

            // Store the variable name for later insertion into the symbol table
            var_list.push_back($1-> get_name());
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD
 		  {
 		  	outlog<<"At line no: "<<lines<<" declaration_list : ID LTHIRD CONST_INT RTHIRD "<<endl<<endl;
			outlog<<$1-> get_name()<<"["<<$3-> get_name()<<"]"<<endl<<endl;

            $$ = new symbol_info($1-> get_name()+"["+$3-> get_name()+"]","dec_list");

            // Store the array name and size for later insertion into the symbol table
            symbol_info* sym = new symbol_info($1-> get_name(), "ARRAY");
            sym->set_array_size(stoi($3-> get_name())); // Store array size
            var_list.push_back($1-> get_name()); // Add to the list for later insertion
 		  }
 		  ;

statements : statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statement "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"stmnts");
	   }
	   | statements statement
	   {
	    	outlog<<"At line no: "<<lines<<" statements : statements statement "<<endl<<endl;
			outlog<<$1-> get_name()<<"\n"<<$2-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+"\n"+$2-> get_name(),"stmnts");
	   }
	   ;

	   
statement : var_declaration
	  {
	    	outlog<<"At line no: "<<lines<<" statement : var_declaration "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"stmnt");
	  }
	  | func_definition
	  {
	  		outlog<<"At line no: "<<lines<<" statement : func_definition "<<endl<<endl;
            outlog<<$1-> get_name()<<endl<<endl;

            $$ = new symbol_info($1-> get_name(),"stmnt");
	  		
	  }
	  | expression_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : expression_statement "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"stmnt");
	  }
	  | compound_statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : compound_statement "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"stmnt");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl<<endl;
			outlog<<"for("<<$3-> get_name()<<$4-> get_name()<<$5-> get_name()<<")\n"<<$7-> get_name()<<endl<<endl;
			
			$$ = new symbol_info("for("+$3-> get_name()+$4-> get_name()+$5-> get_name()+")\n"+$7-> get_name(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"if("<<$3-> get_name()<<")\n"<<$5-> get_name()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3-> get_name()+")\n"+$5-> get_name(),"stmnt");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl<<endl;
			outlog<<"if("<<$3-> get_name()<<")\n"<<$5-> get_name()<<"\nelse\n"<<$7-> get_name()<<endl<<endl;
			
			$$ = new symbol_info("if("+$3-> get_name()+")\n"+$5-> get_name()+"\nelse\n"+$7-> get_name(),"stmnt");
	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
	    	outlog<<"At line no: "<<lines<<" statement : WHILE LPAREN expression RPAREN statement "<<endl<<endl;
			outlog<<"while("<<$3-> get_name()<<")\n"<<$5-> get_name()<<endl<<endl;
			
			$$ = new symbol_info("while("+$3-> get_name()+")\n"+$5-> get_name(),"stmnt");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl<<endl;
			outlog<<"printf("<<$3-> get_name()<<");"<<endl<<endl; 
			
			$$ = new symbol_info("printf("+$3-> get_name()+");","stmnt");
	  }
	  | RETURN expression SEMICOLON
	  {
	    	outlog<<"At line no: "<<lines<<" statement : RETURN expression SEMICOLON "<<endl<<endl;
			outlog<<"return "<<$2-> get_name()<<";"<<endl<<endl;
			
			$$ = new symbol_info("return "+$2-> get_name()+";","stmnt");
	  }
	  ;

expression_statement : SEMICOLON
			{
				outlog<<"At line no: "<<lines<<" expression_statement : SEMICOLON "<<endl<<endl;
				outlog<<";"<<endl<<endl;
				
				$$ = new symbol_info(";","expr_stmt");
	        }			
			| expression SEMICOLON 
			{
				outlog<<"At line no: "<<lines<<" expression_statement : expression SEMICOLON "<<endl<<endl;
				outlog<<$1-> get_name()<<";"<<endl<<endl;
				
				$$ = new symbol_info($1-> get_name()+";","expr_stmt");
	        }
			;

variable : ID 	
      {
	    outlog<<"At line no: "<<lines<<" variable : ID "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
			
		$$ = new symbol_info($1-> get_name(),"varbl");
		
	 }	
	 | ID LTHIRD expression RTHIRD 
	 {
	 	outlog<<"At line no: "<<lines<<" variable : ID LTHIRD expression RTHIRD "<<endl<<endl;
		outlog<<$1-> get_name()<<"["<<$3-> get_name()<<"]"<<endl<<endl;
		
		$$ = new symbol_info($1-> get_name()+"["+$3-> get_name()+"]","varbl");
	 }
	 ;

expression : logic_expression
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"expr");
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<"="<<$3-> get_name()<<endl<<endl;

			$$ = new symbol_info($1-> get_name()+"="+$3-> get_name(),"expr");
	   }
	   ;
			
logic_expression : rel_expression
	     {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"lgc_expr");
	     }	
		 | rel_expression LOGICOP rel_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" logic_expression : rel_expression LOGICOP rel_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<$2-> get_name()<<$3-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+$2-> get_name()+$3-> get_name(),"lgc_expr");
	     }	
		 ;
			
rel_expression	: simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"rel_expr");
	    }
		| simple_expression RELOP simple_expression
		{
	    	outlog<<"At line no: "<<lines<<" rel_expression : simple_expression RELOP simple_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<$2-> get_name()<<$3-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+$2-> get_name()+$3-> get_name(),"rel_expr");
	    }
		;
				
simple_expression : term
          {
	    	outlog<<"At line no: "<<lines<<" simple_expression : term "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"simp_expr");
			
	      }
		  | simple_expression ADDOP term 
		  {
	    	outlog<<"At line no: "<<lines<<" simple_expression : simple_expression ADDOP term "<<endl<<endl;
			outlog<<$1-> get_name()<<$2-> get_name()<<$3-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+$2-> get_name()+$3-> get_name(),"simp_expr");
	      }
		  ;
					
term :	unary_expression 
     {
	    	outlog<<"At line no: "<<lines<<" term : unary_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"term");
			
	 }
     |  term MULOP unary_expression
     {
	    	outlog<<"At line no: "<<lines<<" term : term MULOP unary_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<$2-> get_name()<<$3-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+$2-> get_name()+$3-> get_name(),"term");
			
	 }
     ;

unary_expression : ADDOP unary_expression  
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : ADDOP unary_expression "<<endl<<endl;
			outlog<<$1-> get_name()<<$2-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name()+$2-> get_name(),"un_expr");
	     }
		 | NOT unary_expression 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : NOT unary_expression "<<endl<<endl;
			outlog<<"!"<<$2-> get_name()<<endl<<endl;
			
			$$ = new symbol_info("!"+$2-> get_name(),"un_expr");
	     }
		 | factor 
		 {
	    	outlog<<"At line no: "<<lines<<" unary_expression : factor "<<endl<<endl;
			outlog<<$1-> get_name()<<endl<<endl;
			
			$$ = new symbol_info($1-> get_name(),"un_expr");
	     }
		 ;

factor	: variable
    {
	    outlog<<"At line no: "<<lines<<" factor : variable "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
			
		$$ = new symbol_info($1-> get_name(),"fctr");
	}
	| ID LPAREN argument_list RPAREN
	{
	    outlog<<"At line no: "<<lines<<" factor : ID LPAREN argument_list RPAREN "<<endl<<endl;
		outlog<<$1-> get_name()<<"("<<$3-> get_name()<<")"<<endl<<endl;

		$$ = new symbol_info($1-> get_name()+"("+$3-> get_name()+")","fctr");
	}
	| LPAREN expression RPAREN
	{
	   	outlog<<"At line no: "<<lines<<" factor : LPAREN expression RPAREN "<<endl<<endl;
		outlog<<"("<<$2-> get_name()<<")"<<endl<<endl;
		
		$$ = new symbol_info("("+$2-> get_name()+")","fctr");
	}
	| CONST_INT 
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_INT "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
			
		$$ = new symbol_info($1-> get_name(),"fctr");
	}
	| CONST_FLOAT
	{
	    outlog<<"At line no: "<<lines<<" factor : CONST_FLOAT "<<endl<<endl;
		outlog<<$1-> get_name()<<endl<<endl;
			
		$$ = new symbol_info($1-> get_name(),"fctr");
	}
	| variable INCOP 
	{
	    outlog<<"At line no: "<<lines<<" factor : variable INCOP "<<endl<<endl;
		outlog<<$1-> get_name()<<"++"<<endl<<endl;
			
		$$ = new symbol_info($1-> get_name()+"++","fctr");
	}
	| variable DECOP
	{
	    outlog<<"At line no: "<<lines<<" factor : variable DECOP "<<endl<<endl;
		outlog<<$1-> get_name()<<"--"<<endl<<endl;
			
		$$ = new symbol_info($1-> get_name()+"--","fctr");
	}
	;

argument_list : arguments
			  {
					outlog<<"At line no: "<<lines<<" argument_list : arguments "<<endl<<endl;
					outlog<<$1-> get_name()<<endl<<endl;
						
					$$ = new symbol_info($1-> get_name(),"arg_list");
			  }
			  |
			  {
					outlog<<"At line no: "<<lines<<" argument_list :  "<<endl<<endl;
					outlog<<""<<endl<<endl;
						
					$$ = new symbol_info("","arg_list");
			  }
			  ;
	
arguments : arguments COMMA logic_expression
		  {
				outlog<<"At line no: "<<lines<<" arguments : arguments COMMA logic_expression "<<endl<<endl;
				outlog<<$1-> get_name()<<","<<$3-> get_name()<<endl<<endl;
						
				$$ = new symbol_info($1-> get_name()+","+$3-> get_name(),"arg");
		  }
	      | logic_expression
	      {
				outlog<<"At line no: "<<lines<<" arguments : logic_expression "<<endl<<endl;
				outlog<<$1-> get_name()<<endl<<endl;
						
				$$ = new symbol_info($1-> get_name(),"arg");
		  }
	      ;
type_specifier : INT
        {
            outlog<<"At line no: "<<lines<<" type_specifier : INT "<<endl<<endl;
            outlog<<"int"<<endl<<endl;

            $$ = new symbol_info("int", "type");
        }
    | FLOAT
        {
            outlog<<"At line no: "<<lines<<" type_specifier : FLOAT "<<endl<<endl;
            outlog<<"float"<<endl<<endl;

            $$ = new symbol_info("float", "type");
        }
    | CHAR
        {
            outlog<<"At line no: "<<lines<<" type_specifier : CHAR "<<endl<<endl;
            outlog<<"char"<<endl<<endl;

            $$ = new symbol_info("char", "type");
        }
    | VOID
        {
            outlog<<"At line no: "<<lines<<" type_specifier : VOID "<<endl<<endl;
            outlog<<"void"<<endl<<endl;

            $$ = new symbol_info("void", "type");
        }
    | DOUBLE
        {
            outlog<<"At line no: "<<lines<<" type_specifier : DOUBLE "<<endl<<endl;
            outlog<<"double"<<endl<<endl;

            $$ = new symbol_info("double", "type");
        }
    ;
 
%%

int main(int argc, char *argv[])
{
	if(argc != 2) 
	{
		cout<<"Please input file name"<<endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("my_log.txt", ios::trunc);
	
	if(yyin == NULL)
	{
		cout<<"Couldn't open file"<<endl;
		return 0;
	}
	// Enter the global or the first scope here
	st->enter_scope();
	outlog<<"New ScopeTable with ID 1 created"<<endl<<endl;


	yyparse();
	
	outlog<<endl<<"Total lines: "<<lines<<endl;
	
	outlog.close();
	
	fclose(yyin);
	
	return 0;
}