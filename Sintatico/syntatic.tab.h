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
    T_Comma = 258,                 /* T_Comma  */
    T_Assignment = 259,            /* T_Assignment  */
    T_Elem = 260,                  /* T_Elem  */
    T_If = 261,                    /* T_If  */
    T_Else = 262,                  /* T_Else  */
    T_LeftBrace = 263,             /* T_LeftBrace  */
    T_LeftParentheses = 264,       /* T_LeftParentheses  */
    T_Period = 265,                /* T_Period  */
    T_RightBrace = 266,            /* T_RightBrace  */
    T_RightParentheses = 267,      /* T_RightParentheses  */
    T_Semicolon = 268,             /* T_Semicolon  */
    T_Set = 269,                   /* T_Set  */
    LOGICAL_AND_OP = 270,          /* LOGICAL_AND_OP  */
    LOGICAL_OR_OP = 271,           /* LOGICAL_OR_OP  */
    T_For = 272,                   /* T_For  */
    T_Return = 273,                /* T_Return  */
    T_Write = 274,                 /* T_Write  */
    T_Writeln = 275,               /* T_Writeln  */
    T_Read = 276,                  /* T_Read  */
    T_Empty = 277,                 /* T_Empty  */
    T_Type_Float = 278,            /* T_Type_Float  */
    T_Type_Int = 279,              /* T_Type_Int  */
    T_SetForAll = 280,             /* T_SetForAll  */
    T_SetIsSet = 281,              /* T_SetIsSet  */
    T_SetIn = 282,                 /* T_SetIn  */
    T_SetBasic = 283,              /* T_SetBasic  */
    ENUMERATOR_OP = 284,           /* ENUMERATOR_OP  */
    T_Integer = 285,               /* T_Integer  */
    T_Float = 286,                 /* T_Float  */
    T_Basic_type = 287,            /* T_Basic_type  */
    T_Id = 288,                    /* T_Id  */
    RELATIONAL_OP = 289,           /* RELATIONAL_OP  */
    MULTIPLICATIVE_OP = 290,       /* MULTIPLICATIVE_OP  */
    ADDITIVE_OP = 291,             /* ADDITIVE_OP  */
    T_String = 292,                /* T_String  */
    T_SET_OPERATION = 293          /* T_SET_OPERATION  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 24 "syntatic.y"

	char* body;

#line 106 "syntatic.tab.h"

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
