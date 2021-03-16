/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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

#ifndef YY_YY_SYNTATIC_TAB_H_INCLUDED
# define YY_YY_SYNTATIC_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_Comma = 258,
    T_Assignment = 259,
    T_Elem = 260,
    T_If = 261,
    T_Else = 262,
    T_LeftBrace = 263,
    T_LeftParentheses = 264,
    T_Period = 265,
    T_RightBrace = 266,
    T_RightParentheses = 267,
    T_Semicolon = 268,
    T_Set = 269,
    LOGICAL_AND_OP = 270,
    LOGICAL_OR_OP = 271,
    T_SET_OPERATION_1 = 272,
    T_SET_OPERATION_2 = 273,
    T_SET_OPERATION_3 = 274,
    T_For = 275,
    T_Return = 276,
    T_Write = 277,
    T_Writeln = 278,
    T_Read = 279,
    T_Empty = 280,
    T_Type_Float = 281,
    T_Type_Int = 282,
    ENUMERATOR_OP = 283,
    T_Integer = 284,
    T_Float = 285,
    T_Basic_type = 286,
    T_Id = 287,
    RELATIONAL_OP = 288,
    MULTIPLICATIVE_OP = 289,
    ADDITIVE_OP = 290,
    T_String = 291,
    T_SET_OPERATION = 292
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 22 "syntatic.y" /* yacc.c:1909  */

	char* body;

#line 96 "syntatic.tab.h" /* yacc.c:1909  */
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
