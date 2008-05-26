CC=sbcl --noinform --eval '(compile-file "
CCEND=")' --eval '(quit)'


default: fink.fasl

fink.fasl: 
	sbcl --noinform --load 'env.lisp'  --eval '(quit)'

#$(CC)env.lisp$(CCEND)
#$(CC)fink.lisp$(CCEND)

clean:
	rm *.fasl
