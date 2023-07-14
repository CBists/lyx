package lyx

import (
	"bufio"
	"fmt"
)

%%{ 
    machine lexer;
    write data;
    access lex.;
    variable p lex.p;
    variable pe lex.pe;
}%%

type Lexer struct {
	data         []byte
	p, pe, cs    int
	ts, te, act  int

	result []string
}

func NewLexer(data []byte) *Lexer {
    lex := &Lexer{ 
        data: data,
        pe: len(data),
    }
    %% write init;
    return lex
}


func Run(scanner *bufio.Scanner) {
	for scanner.Scan() {
		l := scanner.Text()

		tt := NewLexer([]byte(l))
		ySym := new(yySymType)
		for {
			v := tt.Lex(ySym)
			if v == 0 {
				fmt.Println("end")
                break;
			} else {
				fmt.Printf("token type %d\n", v)
			}
		}
	}
}


func (l *Lexer) Error(msg string) {
	println(msg)
}


func (lex *Lexer) Lex(lval *yySymType) int {
    eof := lex.pe
    var tok int

    %%{
        # /* digit = [0-9] ; already defined */


#        xcstart		=	\/\*{op_chars}*;
#        xcstop		=	\*+\/;
#        xcinside	=	[^*/]+;

        ident_start	=	[A-Za-z\200-\377_];
        ident_cont	=	[A-Za-z\200-\377_0-9$];

        identifier	=	ident_start ident_cont*;

        qidentifier	=	'"' ident_start ident_cont* '"' ;


#        space		=	[ \t\n\r\f];
        horiz_space	= [ \t\f];
        newline		=	[\n\r];
#        non_newline	=	[^\n\r];

#        comment		=	("--"{non_newline}*);


        comment		= '/''*' (any - '*''/')* '*''/';


#       whitespace	=	({space}+|{comment});
        whitespace	=	space+;


        op_chars	=	( '~' | '!' | '@' | '#' | '^' | '&' | '|' | '`' | '?' | '+' | '-' | '*' | '\\' | '%' | '<' | '>' | '=' ) ;
        operator	=	op_chars+;

        integer = digit+;

        sconst = '\'' (any-'\'')* '\'';
        
        main := |*
            whitespace => { /* do nothing */ };
            # integer const is string const 
            comment => {/* nothing */};
            integer =>  { lval.str = string(lex.data[lex.ts:lex.te]); tok = SCONST; fbreak;};

            /select/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = SELECT; fbreak;};
            /insert/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = INSERT; fbreak;};
            /into/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = INTO; fbreak;};
            /values/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = VALUES; fbreak;};
            /update/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = UPDATE; fbreak;};
            /delete/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = DELETE; fbreak;};
            /create/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = CREATE; fbreak;};
            /table/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TABLE; fbreak;};
            /database/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = DATABASE; fbreak;};
            /role/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = ROLE; fbreak;};
            /primary/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = PRIMARY; fbreak;};
            /foreign/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = FOREIGN; fbreak;};
            /references/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = REFERENCES; fbreak;};
            /key/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = KEY; fbreak;};
            /set/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = SET; fbreak;};
            /from/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = FROM; fbreak;};
            /where/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = WHERE; fbreak;};
            /order/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = ORDER; fbreak;};
            /group/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = GROUP; fbreak;};
            /by/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = BY; fbreak;};
            /as/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = AS; fbreak;};
            /and/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = AND; fbreak;};
            /or/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = OR; fbreak;};

            /returning/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = RETURNING; fbreak;};
            /default/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = DEFAULT; fbreak;};
            
            /copy/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = COPY; fbreak;};
            /to/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TO; fbreak;};
            /stdout/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = STDOUT; fbreak;};

            /limit/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = LIMIT; fbreak;};
            

            /join/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = JOIN; fbreak;};
            /cross/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = CROSS; fbreak;};
            /full/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = FULL; fbreak;};
            /outer/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = OUTER_P; fbreak;};
            /inner/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = INNER_P; fbreak;};
            /on/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = ON; fbreak;};
            /for/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = FOR; fbreak;};

            /vacuum/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = VACUUM; fbreak;};
            /cluster/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = CLUSTER; fbreak;};
            /analyze/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = ANALYZE; fbreak;};

            /alter/i => { lval.str = string(lex.data[lex.ts:lex.te]); tok = ALTER; fbreak;};

            qidentifier      => { lval.str = string(lex.data[lex.ts + 1:lex.te - 1]); tok = IDENT; fbreak;};
            identifier      => { lval.str = string(lex.data[lex.ts:lex.te]); tok = IDENT; fbreak;};
            sconst      => { lval.str = string(lex.data[lex.ts + 1:lex.te - 1]); tok = SCONST; fbreak;};


#           self		=	(',' | '(' | ')' | '[' | ']' | '.' | ';'| ':' | '+' | '-' | '*' | '\\' | '%' | '^' | '<' | '>' | '=');

            ',' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TCOMMA; fbreak;};
            '(' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TOPENBR; fbreak;};
            ')' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TCLOSEBR; fbreak;};
            '[' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TSQCLOSEBR; fbreak;};
            ']' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TSQCLOSEBR; fbreak;};
            '.' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TDOT; fbreak;};
            ';' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TSEMICOLON; fbreak;};
            ':' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TCOLON; fbreak;};
            '+' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TPLUS; fbreak;};
            '-' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TMINUS; fbreak;};
            '*' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TMUL; fbreak;};
           # TODO: support '\\' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = int(TMUL); fbreak;};
            '%' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TMOD; fbreak;};
            '^' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TPOW; fbreak;};
            '<' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TLESS; fbreak;};
            '>' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TGREATER; fbreak;};
            '=' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TEQ; fbreak;};

            '<>' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TNOT_EQUALS; fbreak;};
            '<=' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TLESS_EQUALS; fbreak;};
            '>=' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TGREATER_EQUALS; fbreak;};
            '!=' => { lval.str = string(lex.data[lex.ts:lex.te]); tok = TNOT_EQUALS; fbreak;};


            operator => {
                lval.str = string(lex.data[lex.ts:lex.te]); tok = int(OP);    
                fbreak;
            };

#            self => {
#
#            }
        *|;

        write exec;
    }%%

    return int(tok);
}