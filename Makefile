subdirs=hello1 hello1c common

all:
	for i in $(subdirs); do make -C $$i || break; done

clean:
	for i in $(subdirs); do make -C $$i clean || break; done
	find -name \*~ -delete

