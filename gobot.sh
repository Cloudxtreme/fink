#!/bin/sh 
#echo $1 $2
#/usr/bin/sbcl --noinform  --load /home/dan/src/my/gobot/packages.lisp --load /home/dan/src/my/gobot/gobot.lisp /home/dan/src/my/gobot/gtp.lisp --eval "(progn (gtp-handler:gtp-net-client \"$1\" $2) (quit))"  2>&1 /dev/null

/usr/bin/sbcl --noinform --load /home/dan/src/my/gobot/fink.lisp --eval "(progn (gtp-handler:gtp-net-client \"$1\" $2) (quit))"

#/usr/bin/sbcl --noinform --load /home/dan/src/my/gobot/env.lisp --eval "(progn (gtp-handler:gtp-client) (quit))"
