#!/bin/sh

sbcl --noinform --load fink.fasl --eval '(gtp-handler:gtp-client)' --eval '(quit)'
