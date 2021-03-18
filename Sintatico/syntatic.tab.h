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
    AND_OP = 262,                  /* AND_OP  */
    OR_OP = 263,                   /* OR_OP  */
    FOR = 264,                     /* FOR  */
    RETURN = 265,                  /* RETURN  */
    WRITE = 266,                   /* WRITE  */
    WRITELN = 267,                 /* WRITELN  */
    READ = 268,                    /* READ  */
    EMPTY = 269,                   /* EMPTY  */
    FLOAT = 270,                   /* FLOAT  */
    INT = 271,                     /* INT  */
    ADD = 272,                     /* ADD  */
    REMOVE = 273,                  /* REMOVE  */
    EXISTS = 274,                  /* EXISTS  */
    FOR_ALL = 275,                 /* FOR_ALL  */
    IS_SET = 276,                  /* IS_SET  */
    IN = 277,                      /* IN  */
    INT_VALUE = 278,               /* INT_VALUE  */
    FLOAT_VALUE = 279,             /* FLOAT_VALUE  */
    ID = 280,                      /* ID  */
    RELATIONAL_OP = 281,           /* RELATIONAL_OP  */
    MULTIPLICATIVE_OP = 282,       /* MULTIPLICATIVE_OP  */
    ADDITIVE_OP = 283,             /* ADDITIVE_OP  */
    STRING = 284                   /* STRING  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 23 "syntatic.y"

	char* body;

#line 97 "syntatic.tab.h"

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
