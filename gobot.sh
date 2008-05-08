#!/bin/sh 

/usr/bin/sbcl --noinform --load /home/dan/src/my/gobot/env.lisp --eval "(progn (gtp-handler:gtp-net-client \"$1\" $2) (quit))"
