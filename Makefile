#  
# Books.app Makefile
#

CC=arm-apple-darwin-gcc
CFLAGS=-O3
CPPFLAGS=-I/opt/local/include
LD=$(CC)
LDFLAGS=-L$(HEAVENLY)/usr/lib -L/usr/local/lib/gcc/arm-apple-darwin/4.0.1 \
	-lz -lobjc -lgcc -framework CoreFoundation -framework Foundation \
	-framework UIKit -framework LayerKit -framework CoreGraphics \
	-framework GraphicsServices -lcrypto

VERSION=$(shell ./getversion.sh)

SOURCES=$(wildcard source/palm/*.c source/palm/*.m source/*.c source/*.m)
OBJECTS=$(patsubst source/%,obj/%,$(patsubst source/palm/%,obj/%, \
	$(patsubst %.c,%.o,$(filter %.c,$(SOURCES))) \
	$(patsubst %.m,%.o,$(filter %.m,$(SOURCES))) \
	$(patsubst %.cpp,%.o,$(filter %.cpp,$(SOURCES))) \
))

IMAGES=$(wildcard images/*.png)

ARCHIVE=Books-$(VERSION).zip

BASEURL=http://www.thebedells.org/books/
SCP_BASE=www:~/wwwroot/books/

QUIET=true

ifeq ($(QUIET),true)
	QC	= @echo "Compiling [$@]";
	QL	= @echo "Linking   [$@]";
	QN	= > /dev/null 2>&1
else
	QC	=
	QL	= 
	QN	=
endif

all:    Books

test:
	echo $(OBJECTS)
	
bundle: Books.app

Books: obj/Books

obj/Books:  $(OBJECTS) lib/libjpeg.a
	$(QL)$(LD) $(LDFLAGS) -v -o $@ $^ $(QN)

obj/%.o:    source/%.m
	@mkdir -p obj
	$(QC)$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

obj/%.o:    source/%.c
	@mkdir -p obj
	$(QC)$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

obj/%.o:    source/palm/%.m
	@mkdir -p obj
	$(QC)$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

obj/%.o:    source/palm/%.c
	@mkdir -p obj
	$(QC)$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -rf obj Books.app Books-*.tbz repo.xml
	
obj/Info.plist: Info.plist.tmpl
	@echo "Building Info.plist for version $(VERSION)."
	@sed -e 's|__VERSION__|$(VERSION)|g' < $< > $@

repo.xml: repo.xml.tmpl package
	sed -e 's|__VERSION__|$(VERSION)|g' -e 's|__PKG_SIZE__|$(shell ./filesize.sh $(ARCHIVE))|g' -e 's|__RELEASE_DATE__|$(shell date +%s)|g' -e 's|__PKG_URL__|$(BASEURL)$(ARCHIVE)|g' < repo.xml.tmpl > $@

Books.app: obj/Books obj/Info.plist $(IMAGES)
	@echo "Creating application bundle."
	@rm -fr Books.app
	@mkdir -p Books.app
	@cp $^ Books.app/
	@rm Books.app/Default.png
	@ln  -s '~/Library/Books/Default.png' Books.app/Default.png
	
deploy: obj/Books
	scp obj/Books iphone:/Applications/Books.app/
	ssh iphone chmod +x /Applications/Books.app/Books

deploy-app: bundle
	scp -r Books.app root@iphone:/Applications/
	ssh root@iphone chmod +x /Applications/Books.app/Books

package: bundle
	zip -r9 $(ARCHIVE) Books.app images/Default.png
	
deploy-repo: package repo.xml
	scp $(ARCHIVE) $(SCP_BASE)
	scp repo.xml $(SCP_BASE)

