VERSION=0.1.4

meteor-spk.deps: mongo/mongod mongo-tools/bin/mongorestore mongo-tools/bin/mongodump niscu/mongod gather-deps.sh start.js
	@echo "**** Gathering dependencies..."
	./gather-deps.sh

mongo-tools/build.sh:
	@echo "**** ERROR: You need to do 'git submodule init; git submodule update' ****"
	@false

mongo-tools/bin/mongodump mongo-tools/bin/mongorestore: mongo-tools/build.sh
	cd mongo-tools && ./build.sh

# The following rule is only triggered if the person who
# cloned this repo forgot to clone with "git clone --recursive".
#
# We use "false" to cause make to stop processing.
mongo/SConstruct:
	@echo "**** ERROR: You need to do 'git submodule init; git submodule update' ****"
	@false

mongo/mongod: mongo/SConstruct
	@echo "**** Building MongoDB (modified MongoDB)..."
	cd mongo && scons -j6 mongod mongodump mongorestore --disable-warnings-as-errors

niscu/SConstruct:
	@echo "**** ERROR: You need to do 'git submodule init; git submodule update' ****"
	@false

niscu/mongod: niscu/SConstruct
	@echo "**** Building NiscuDB (modified MongoDB)..."
	cd niscu && scons -j6 mongod --cxx="g++ -Wno-error=unused-variable -Wno-error=strict-overflow" --cc="gcc"

dist: meteor-spk-$(VERSION).tar.xz

meteor-spk-$(VERSION).tar.xz: meteor-spk meteor-spk.deps README.md NOTICE
	tar --transform 's,^,meteor-spk-$(VERSION)/,rSh' -Jcf meteor-spk-$(VERSION).tar.xz meteor-spk meteor-spk.deps README.md NOTICE

push: meteor-spk-$(VERSION).tar.xz
	grep -q "meteor-spk-$(VERSION)[.]tar" README.md
	gcutil push fe meteor-spk-$(VERSION).tar.xz /var/www/dl.sandstorm.io/meteor-spk-$(VERSION).tar.xz

clean:
	rm -rf meteor-spk.deps tmp meteor-spk-$(VERSION).tar.xz
	cd mongo && scons -c

.PHONY: dist clean push
