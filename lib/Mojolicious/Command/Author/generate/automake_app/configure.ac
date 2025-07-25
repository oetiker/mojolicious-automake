#  Copyright (C) <%= ${year} %> <%= ${fullName} %>

AC_INIT([<%= ${filename} %>],m4_esyscmd([tr -d '\n' < VERSION]),[<%= ${email} %>])
AC_PREREQ([2.59])
AC_CONFIG_AUX_DIR(conftools)

MJ_CLASS=<%= ${class} %>
MJ_SCRIPT=<%= ${filename} %>
% if ($package eq 'callbackery' ) {
QX_CLASS=<%= ${class_file} %>
% } 

AC_SUBST(MJ_CLASS)
AC_SUBST(MJ_SCRIPT)
AC_SUBST(QX_CLASS)

# need this to allow long path names
AM_INIT_AUTOMAKE([1.9 tar-ustar foreign])
AM_MAINTAINER_MODE

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_PREFIX_DEFAULT(/opt/$PACKAGE_NAME-$PACKAGE_VERSION)

AC_ARG_VAR(PERL,   [Path to local perl binary])
AC_PATH_PROG(PERL, perl, no)
AC_PATH_PROG(CURL, curl, no)
AC_PATH_PROG(WGET, wget, no)
% if ($package eq 'callbackery' ) {
AC_ARG_VAR(NODE,   [Path to local node binary])
AC_PATH_PROG(NODE, node, no)
AC_PATH_PROG(NPM, npm, npm-not-found)
AC_PATH_PROG(NPX, npx, npx-not-found)
AC_PATH_PROG(XGETTEXT, xgettext, xgettext-not-found)
AC_PATH_PROG(MSGMERGE, msgmerge, msgmerge-not-found)
% }


URL_CAT="neither curl nor wget found"

if test -x "$CURL"; then
    URL_CAT="$CURL --location --insecure"
else
    if test -x "$WGET"; then
        URL_CAT="$WGET -O -"
    fi
fi

AC_SUBST(URL_CAT)

ac_perl_version="5.22.0"

if test -x "$PERL"; then
  AC_MSG_CHECKING(for perl version greater than or equal to $ac_perl_version)
  $PERL -e "use $ac_perl_version;" >/dev/null 2>&1
  if test $? -ne 0; then
    AC_MSG_RESULT(no);
    AC_MSG_ERROR(at least version ${ac_perl_version} is required to run mojolicious)
  else
    AC_MSG_RESULT(ok);
  fi
else
  AC_MSG_ERROR(could not find perl)
fi

% if ($package eq 'callbackery' ) {

ac_node_version="20"

AC_MSG_CHECKING(for node version greater than or equal to $ac_node_version)
if $PERL -e 'if (`'$NODE' --version` =~ /v(\d+)/ and $1 >= '$ac_node_version') { exit 1 }'; then
   NODE=old-node-found
   AC_MSG_RESULT(at least version ${ac_node_version} is required to re-build the fontend)   
else
   AC_MSG_RESULT(ok);
fi


AM_CONDITIONAL(BUILD_QOOXDOO_APP,[test -x $NODE])
% }

AC_PATH_PROG(OPENSSL, openssl, no)
if  test -x "$OPENSSL"; then
:
else
  AC_MSG_ERROR(could not find openssl binary)
fi

AC_MSG_CHECKING(is perl reasonably complete)
if $PERL -MExtUtils::MakeMaker -e '' 2>/dev/null; then
  AC_MSG_RESULT(yes. ExtUtils::MakeMaker is available);
else
  AC_MSG_RESULT(no)
  AC_MSG_ERROR([a complete perl ('perl-core' in the redhat world) installation is required])
fi

AC_MSG_CHECKING([if we require a c compiler to get perl modules compiled])
if $PERL -MIO::Socket::IP -e 'exit($IO::Socket::IP::VERSION >= 0.37)' 2>/dev/null; then
    AC_MSG_RESULT(no)
else
    AC_MSG_RESULT(yes)
    perl_cc=`$PERL -MConfig -e 'print $Config{cc}'`
    AC_PATH_PROG(PERL_CC_PATH, $perl_cc, no)
    AC_MSG_CHECKING(is perls favorite c compiler ($perl_cc) available)
    if test x$PERL_CC_PATH = xno; then
      AC_MSG_RESULT(no)
      AC_MSG_ERROR([perl needs the '$perl_cc' compiler package to build dependencies])
    else
      AC_MSG_RESULT(yes)
    fi
fi


AC_PROG_GREP

AC_ARG_VAR(GMAKE,   [Path to local GNU Make binary])
AC_PATH_PROGS(GMAKE, [gnumake gmake make])

AC_MSG_CHECKING([for gnu make availablility])
if  ( $GMAKE --version 2> /dev/null | $GREP GNU  > /dev/null 2>&1 );  then
    AC_MSG_RESULT([$GMAKE is GNU make])
else
    AC_MSG_ERROR([GNU make not found. Try setting the GMAKE environment variable.])
fi

AC_ARG_ENABLE(pkgonly,
        AC_HELP_STRING([--enable-pkgonly],
                        [Skip all checking]))
AC_SUBST(enable_pkgonly)

actual_prefix=$prefix
if test "$actual_prefix" = "NONE"; then
    actual_prefix=$ac_default_prefix
fi

AC_MSG_CHECKING([Checking Install Prefix])
if test -f "$actual_prefix/configure"; then
    AC_MSG_ERROR([The install prefix must NOT point to the directory where you unpacked the source.])
else
    AC_MSG_RESULT([install Prefix is fine])
fi

% if ($package eq 'callbackery' ) {
AC_ARG_VAR(CALLBACKERY_QX, [Alternate CallBackery/qooxdoo folder location])
if test "$CALLBACKERY_QX" = ""; then
    script_path=`dirname "$0"`
    script_path=`cd $script_path;pwd`
    # Absolute path this script is in, thus /home/user/bin
    CALLBACKERY_QX="$script_path"/thirdparty/lib/perl5/CallBackery/qooxdoo
fi
AC_SUBST(CALLBACKERY_QX)
% }

AC_ARG_VAR(PERL5LIB,   [Colon separated list of perl library directories])
AC_SUBST(PERL5LIB)

AC_CONFIG_FILES([
    Makefile
    etc/Makefile
    lib/Makefile
    bin/Makefile<%= $package eq 'callbackery' ? "\nfrontend/Makefile" : "" %>
    thirdparty/Makefile
])

AC_SUBST(VERSION)

AC_OUTPUT

% if ($package eq 'callbackery' ) {

if test -x "$NODE"; then
:
else
cat <<NOTES

** WARNING ***********************************************

To run the qooxdoo compiler, at least node v$ac_node_version is required.
Use mise to setup a local copy of node. https://mise.jdx.dev/

NOTES
fi

% }

cat <<NOTES

** CONFIGURE DONE **********************************************

Settings:

  PERL5LIB = ${PERL5LIB:-"not set"}
  PERL = $PERL

The Makefiles use GNU make functionality.
Continue installation with

  $GMAKE install

NOTES
