/* A Bison parser, made by GNU Bison 3.7.6.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_SYNTATIC_TAB_H_INCLUDED
# define YY_YY_SYNTATIC_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    ELEM = 258,                    /* ELEM  */
    IF = 259,                      /* IF  */
    ELSE = 260,                    /* ELSE  */
    SET = 261,                     /* SET  */
    FOR = 262,                     /* FOR  */
    RETURN = 263,                  /* RETURN  */
    WRITE = 264,                   /* WRITE  */
    WRITELN = 265,                 /* WRITELN  */
    READ = 266,                    /* READ  */
    EMPTY = 267,                   /* EMPTY  */
    FLOAT = 268,                   /* FLOAT  */
    INT = 269,                     /* INT  */
    ADD = 270,                     /* ADD  */
    REMOVE = 271,                  /* REMOVE  */
    EXISTS = 272,                  /* EXISTS  */
    FOR_ALL = 273,                 /* FOR_ALL  */
    IS_SET = 274,                  /* IS_SET  */
    IN = 275,                      /* IN  */
    INT_VALUE = 276,               /* INT_VALUE  */
    FLOAT_VALUE = 277,             /* FLOAT_VALUE  */
    ID = 278,                      /* ID  */
    STRING = 279,                  /* STRING  */
    RELATIONAL_OP = 280,           /* RELATIONAL_OP  */
    MULTIPLICATIVE_OP = 281,       /* MULTIPLICATIVE_OP  */
    ADDITIVE_OP = 282,             /* ADDITIVE_OP  */
    AND_OP = 283,                  /* AND_OP  */
    OR_OP = 284                    /* OR_OP  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 24 "syntatic.y"


    struct Body {
        char tokenBody [2000];
        int line;
        int column;
        int scope;
    } body;

    struct TreeNode *node;

#line 105 "syntatic.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE YYLTYPE;
struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


extern YYSTYPE yylval;
extern YYLTYPE yylloc;
int yyparse (void);

#endif /* !YY_YY_SYNTATIC_TAB_H_INCLUDED  */
