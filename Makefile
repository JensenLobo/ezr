# Default is show help; e.g.
#
#    make 
#
# prints the help text.

SHELL     := bash
MAKEFLAGS += --warn-undefined-variables
.SILENT:

Top=$(shell git rev-parse --show-toplevel)

help      :  ## show help
		gawk -f $(Top)/etc/help.awk $(MAKEFILE_LIST) 

pull    : ## download
	git pull

push    : ## save
	echo -n "> Why this push? "; read x; git commit -am "$$x"; git push; git status

md=$(wildcard $(Top)/docs/[A-Z]*.md)

docs2lua: $(subst docs,tests,$(md:.md=.lua)) ## run updates docs/[A-Z]*.md ==> tests/x.lua

$(Top)/tests/%.lua : $(Top)/docs/%.md
	gawk 'BEGIN { code=0 } sub(/^```.*/,"")  \
			{ code = 1 - code } \
			{ print (code ? "" : "-- ") $$0 }' $^ > $@
	luac -p $@


~/tmp/%.pdf: %.lua  ## .lua ==> .pdf
	mkdir -p ~/tmp
	echo "pdf-ing $@ ... "
	a2ps                 \
		-Br                 \
		-l 100                 \
		--file-align=fill      \
		--line-numbers=1        \
		--pro=color               \
		--left-title=""            \
		--borders=no             \
		--pretty-print="$(Top)/etc/lua.ssh" \
		--columns 3                  \
		-M letter                     \
		--footer=""                    \
		--right-footer=""               \
	  -o	 $@.ps $<
	ps2pdf $@.ps $@; rm $@.ps
	open $@
