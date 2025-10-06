# Extract values from pyproject.toml
NAME := $(shell python -c "import tomllib;print(tomllib.load(open('pyproject.toml','rb'))['project']['name'])")
VERSION := $(shell python -c "import tomllib;print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])")
BINARIES := $(shell python -c "import tomllib;data=tomllib.load(open('pyproject.toml','rb'));print(' '.join(data['project']['scripts'].keys()))")
PYTHON_VER := "3.11.1"

PREFIX=/opt/$(NAME)
VENVDIR=$(PREFIX)/venv
BUILDROOT=$(PWD)/buildroot
WHEELHOUSE=$(PWD)/wheelhouse
DISTNAME=$(subst -,_,$(NAME))

UV_PYTHON_INSTALL_DIR := $(BUILDROOT)$(PREFIX)/.uv-python
export UV_PYTHON_INSTALL_DIR

all: install fix-venv-symlinks fix-shebangs fix-pyvenv-cfg wrappers rpm

install:
        mkdir -p $(BUILDROOT)$(PREFIX)
        uv python install $(PYTHON_VER)
        uv venv --relocatable --python $(PYTHON_VER)
        uv venv $(BUILDROOT)$(VENVDIR)
        uv pip install --python $(BUILDROOT)$(VENVDIR)/bin/python setuptools wheel pip
        uv pip install --python $(BUILDROOT)$(VENVDIR)/bin/python .

fix-venv-symlinks:
        # Rewrite python symlink to point into the final prefix, not buildroot path
        for f in $(BUILDROOT)$(VENVDIR)/bin/python*; do \
          if [ -L $$f ]; then \
            target=$$(readlink $$f); \
                echo "$$f -> $$target"; \
            case $$target in \
              $(BUILDROOT)*) \
                new_target=$$(echo $$target | sed -E "s|^$(BUILDROOT)||"); \
                ln -sf "$$new_target" $$f; \
                ;; \
            esac; \
          fi; \
        done

fix-shebangs:
        for f in $(BUILDROOT)$(VENVDIR)/bin/*; do \
            if head -1 $$f | grep -q '^#!.*python'; then \
                sed -i '1s|^#!.*python[0-9.]*|#!$(VENVDIR)/bin/python3|' $$f; \
            fi \
        done

fix-pyvenv-cfg:
        sed -i \
          -e "s|$(BUILDROOT)||g" \
          -e "s|^home = .*|home = $(PREFIX)/.uv-python/cpython-$(PYTHON_VER)-linux-x86_64-gnu/bin|" \
          -e "s|^executable = .*|executable = $(PREFIX)/.uv-python/cpython-$(PYTHON_VER)-linux-x86_64-gnu/bin/python3|" \
          -e "s|^command = .*|command = $(VENVDIR)/bin/python3 -m venv --without-pip --upgrade $(VENVDIR)|" \
          $(BUILDROOT)$(VENVDIR)/pyvenv.cfg

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


