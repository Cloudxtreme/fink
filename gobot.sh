#!/bin/sh 
#echo $1 $2
/usr/bin/sbcl --noinform  --load /home/dan/src/my/gobot/packages.fasl --load /home/dan/src/my/gobot/gobot.fasl /home/dan/src/my/gobot/gtp.fasl --eval "(progn (gtp-handler:gtp-net-client \"$1\" $2) (quit))"  2>&1 /dev/null
#/usr/bin/sbcl --noinform --load /home/dan/src/my/gobot/env.lisp --eval "(progn (gtp-handler:gtp-client) (quit))"
