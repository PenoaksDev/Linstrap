error "Sorry, the help function is not inplemented yet!" "Looking at the files in the root you can get an idea of what functions are available."

warningbox "You must specify a function to continue." "${0} [function] [options]" "Try the 'help' function for more information."

cat <<EOF

GNU bash, version 5.0.17(1)-release-(x86_64-pc-linux-gnu)
  Usage:  bash [GNU long option] [option] ...
          bash [GNU long option] [option] script-file ...
  GNU long options:
          --debug
          --debugger
          --dump-po-strings
          --dump-strings
          --help
          --init-file
          --login
          --noediting
          --noprofile
          --norc
          --posix
          --pretty-print
          --rcfile
          --restricted
          --verbose
          --version
  Shell options:
          -ilrsD or -c command or -O shopt_option         (invocation only)
          -abefhkmnptuvxBCHP or -o option
  Type 'bash -c "help set"' for more information about shell options.
  Type 'bash -c help' for more information about shell builtin commands.
  Use the 'bashbug' command to report bugs.

  bash home page: <http://www.gnu.org/software/bash>
  General help using GNU software: <http://www.gnu.org/gethelp/>

EOF

exit 0