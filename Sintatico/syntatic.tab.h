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
    T_Basic_type = 258,
    T_Comma = 259,
    T_Assignment = 260,
    T_Elem = 261,
    T_If = 262,
    T_Else = 263,
    T_Empty = 264,
    T_Id = 265,
    T_LeftBrace = 266,
    T_LeftParentheses = 267,
    T_Period = 268,
    T_RightBrace = 269,
    T_RightParentheses = 270,
    T_Semicolon = 271,
    T_Set = 272,
    digit = 273,
    ENUMERATOR_OP = 274,
    LOGICAL_AND_OP = 275,
    LOGICAL_OR_OP = 276,
    RELATIONAL_OP = 277,
    MULTIPLICATIVE_OP = 278,
    ADDITIVE_OP = 279,
    T_String = 280,
    identifiers_list = 281,
    T_SET_OPERATION = 282,
    T_SET_OPERATION_1 = 283,
    T_SET_OPERATION_2 = 284,
    T_SET_OPERATION_3 = 285,
    T_For = 286,
    T_Return = 287,
    T_Write = 288,
    T_Writeln = 289,
    T_Read = 290,
    T_In = 291
  };
#endif

/* Value type.  */



int yyparse (void);

#endif /* !YY_YY_SYNTATIC_TAB_H_INCLUDED  */
