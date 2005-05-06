# setenv.m4 serial 3
dnl Copyright (C) 2001-2002 Free Software Foundation, Inc.
dnl This file is free software, distributed under the terms of the GNU
dnl General Public License.  As a special exception to the GNU General
dnl Public License, this file may be distributed as part of a program
dnl that contains a configuration script generated by Autoconf, under
dnl the same distribution terms as the rest of that program.

AC_DEFUN([gt_FUNC_SETENV],
[
  AC_REPLACE_FUNCS(setenv unsetenv)
  if test $ac_cv_func_setenv = no; then
    gl_PREREQ_SETENV
  fi
  if test $ac_cv_func_unsetenv = no; then
    gl_PREREQ_UNSETENV
  fi
])

# Check if a variable is properly declared.
# gt_CHECK_VAR_DECL(includes,variable)
AC_DEFUN([gt_CHECK_VAR_DECL],
[
  define([gt_cv_var], [gt_cv_var_]$2[_declaration])
  AC_MSG_CHECKING([if $2 is properly declared])
  AC_CACHE_VAL(gt_cv_var, [
    AC_TRY_COMPILE([$1
      extern struct { int foo; } $2;],
      [$2.foo = 1;],
      gt_cv_var=no,
      gt_cv_var=yes)])
  AC_MSG_RESULT($gt_cv_var)
  if test $gt_cv_var = yes; then
    AC_DEFINE([HAVE_]translit($2, [a-z], [A-Z])[_DECL], 1,
              [Define if you have the declaration of $2.])
  fi
])

# Prerequisites of lib/setenv.c.
AC_DEFUN([gl_PREREQ_SETENV],
[
  AC_REQUIRE([AC_FUNC_ALLOCA])
  AC_CHECK_HEADERS_ONCE(stdlib.h string.h unistd.h)
  AC_CHECK_HEADERS(search.h)
  AC_CHECK_FUNCS(tsearch)
  gt_CHECK_VAR_DECL([#include <errno.h>], errno)
  gt_CHECK_VAR_DECL([#include <unistd.h>], environ)
])

# Prerequisites of lib/unsetenv.c.
AC_DEFUN([gl_PREREQ_UNSETENV],
[
  AC_CHECK_HEADERS_ONCE(stdlib.h string.h unistd.h)
  gt_CHECK_VAR_DECL([#include <errno.h>], errno)
  gt_CHECK_VAR_DECL([#include <unistd.h>], environ)
])
