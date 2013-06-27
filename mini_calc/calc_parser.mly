%{
open Calc_type
%}

%token <float> FLOAT
%token <string> IDENT
%token <string> FUNC
%token PLUS MINUS TIMES DIV POW
%token LPAREN RPAREN
%token EOL
%left PLUS MINUS        /* lowest precedence */
%left TIMES DIV         /* medium precedence */
%left POW
%nonassoc FUNC
%nonassoc UMINUS        /* highest precedence */
%start main             /* the entry point */
%type <Calc_type.arit_tree> main
%%
main :
	arit EOL { $1 }
;

arit :
	  FLOAT						{ Float $1 }
	| IDENT						{ Id $1 }
	| LPAREN arit RPAREN		{ $2 }
	| arit PLUS arit			{ Op2 ($1,Plus,$3) }
	| arit MINUS arit			{ Op2 ($1,Minus,$3) }
	| arit TIMES arit			{ Op2 ($1,Times,$3) }
	| arit DIV arit				{ Op2 ($1,Div,$3) }
	| arit POW arit				{ Op2 ($1,Pow,$3) }
	| MINUS arit %prec UMINUS	{ Op1 (MinusUn,$2) }
	| FUNC arit					{ Op1 (Func $1,$2) }
;