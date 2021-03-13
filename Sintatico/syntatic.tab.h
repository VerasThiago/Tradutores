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
    T_Integer = 258,
    T_Float = 259,
    T_Bool = 260,
    T_Return = 261,
    T_If = 262,
    T_LeftParentheses = 263,
    T_RightParentheses = 264,
    T_Else = 265,
    T_While = 266,
    T_Write = 267,
    T_Read = 268,
    T_Type = 269,
    T_List = 270,
    T_ListType = 271,
    T_ListOperation = 272,
    T_Id = 273,
    T_Op1 = 274,
    T_Op2 = 275,
    T_Op3 = 276,
    T_assignment = 277,
    T_LeftBrace = 278,
    T_RightBrace = 279,
    T_LeftBracket = 280,
    T_RightBracket = 281,
    T_Semicolon = 282,
    T_Comma = 283
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 27 "syntatic.y" /* yacc.c:1909  */

	Token token;
	Nodo *nodo;

#line 88 "syntatic.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif



int yyparse (void);

#endif /* !YY_YY_SYNTATIC_TAB_H_INCLUDED  */
