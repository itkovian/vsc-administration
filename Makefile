# Extract values from pyproject.toml
NAME := $(shell python -c "import tomllib;print(tomllib.load(open('pyproject.toml','rb'))['project']['name'])")
VERSION := $(shell python -c "import tomllib;print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])")
BINARIES := $(shell python -c "import tomllib;data=tomllib.load(open('pyproject.toml','rb'));print(' '.join(data['project']['scripts'].keys()))")

PREFIX=/opt/$(NAME)
VENVDIR=$(PREFIX)/venv
BUILDROOT=$(PWD)/buildroot
WHEELHOUSE=$(PWD)/wheelhouse
DISTNAME=$(subst -,_,$(NAME))

all: install fix-shebangs wrappers rpm

wheelhouse:
	uv pip compile pyproject.toml --output-file requirements.txt
	uv pip install -r requirements.txt --wheel-dir $(WHEELHOUSE) --only-binary :all:

install:
	uv venv $(BUILDROOT)$(VENVDIR)
	uv pip install --python $(BUILDROOT)$(VENVDIR)/bin/python .

fix-shebangs:
	for f in $(BUILDROOT)$(VENVDIR)/bin/*; do \
	    if head -1 $$f | grep -q '^#!.*python'; then \
	        sed -i '1s|^#!.*python[0-9.]*|#!$(VENVDIR)/bin/python3|' $$f; \
	    fi \
	done

wrappers:
	mkdir -p $(BUILDROOT)/usr/bin
	for bin in $(BINARIES); do \
	    echo "#!/bin/bash\nexec $(VENVDIR)/bin/$$bin \"\$$@\"" > $(BUILDROOT)/usr/bin/$$bin; \
	    chmod +x $(BUILDROOT)/usr/bin/$$bin; \
	done

rpm: wrappers
		fpm -s dir -t rpm \
		    -n $(NAME) \
		    -v $(VERSION) \
		    --prefix=/ \
		    -C $(BUILDROOT) .

clean:
	rm -rf $(BUILDROOT) dist $(WHEELHOUSE) *.rpm requirements.txt

show-vars:
	@echo NAME=$(NAME)
	@echo VERSION=$(VERSION)
	@echo BINARIES=$(BINARIES)
