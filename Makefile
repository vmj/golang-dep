GOLANG?=1.10.3-stretch
DEP?=0.5.0

COMMIT_MSG?="Updated for $(GOLANG) and $(DEP)"

help:
	@echo "Targets:"
	@echo "  pull:   Pull golang:$(GOLANG) and dep $(DEP)"
	@echo "  update: Update Dockerfile and README.adoc with those versions"
	@echo "  build:  Locally build a container image"
	@echo "  commit: git commit the changes (COMMIT_MSG=$(COMMIT_MSG))"
	@echo "  tag:    git tag the HEAD as $(GOLANG)-$(DEP) and push"

pull:
	docker pull golang:$(GOLANG)
	wget -q -O .dep-linux-amd64.sha256 https://github.com/golang/dep/releases/download/v$(DEP)/dep-linux-amd64.sha256
	mv .dep-linux-amd64.sha256 dep-linux-amd64.sha256

update:
	sed -i '' -E \
	    -e "s/FROM golang:.*/FROM golang:$(GOLANG)/" \
	    -e "s/download\\/v[0-9.]+\\/dep/download\\/v$(DEP)\\/dep/" \
	Dockerfile
	sed -i '' -E \
	    -e "s/\`golang:[^\`]+\`/\`golang:$(GOLANG)\`/" \
	    -e "s/\`dep v[^\`]+\`/\`dep v$(DEP)\`/" \
	    -e "s/FROM vmj0\\/golang-dep:[^ ]+ as build/FROM vmj0\\/golang-dep:$(GOLANG)-$(DEP) as build/" \
	README.adoc

build:
	docker build -t vmj0/golang-dep:latest .

commit:
	git add Makefile Dockerfile README.adoc dep-linux-amd64.sha256
	git commit -m $(COMMIT_MSG)
	git push origin master

tag:
	git tag -s -m "$(GOLANG)-$(DEP)" $(GOLANG)-$(DEP)
	git push --tags origin
