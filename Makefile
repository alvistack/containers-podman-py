export GO111MODULE=off
export GOPROXY=https://proxy.golang.org


PYTHON ?= $(shell command -v python3 2>/dev/null || command -v python)
DESTDIR ?= /
DESTDIR ?=
EPOCH_TEST_COMMIT ?= $(shell git merge-base $${DEST_BRANCH:-main} HEAD)
HEAD ?= HEAD

export PODMAN_VERSION ?= "3.2.0"

.PHONY: podman
podman:
	rm dist/* || :
	python -m pip install --user -r requirements.txt
	PODMAN_VERSION=$(PODMAN_VERSION) \
	$(PYTHON) setup.py sdist bdist bdist_wheel

.PHONY: lint
lint:
	$(PYTHON) -m pylint podman || exit $$(($$? % 4));

.PHONY: tests
tests:
	python -m pip install --user -r test-requirements.txt
	DEBUG=1 coverage run -m unittest discover -s podman/tests
	coverage report -m --skip-covered --fail-under=80 --omit=./podman/tests/* --omit=.tox/* \
	--omit=/usr/lib/* --omit=*/lib/python*

.PHONY: unittest
unittest:
	coverage run -m unittest discover -s podman/tests/unit
	coverage report -m --skip-covered --fail-under=80 --omit=./podman/tests/* --omit=.tox/* --omit=/usr/lib/*

.PHONY: integration
integration:
	coverage run -m unittest discover -s podman/tests/integration
	coverage report -m --skip-covered --fail-under=80 --omit=./podman/tests/* --omit=.tox/* --omit=/usr/lib/*

.PHONY: test-release
test-release: SOURCE = $(shell find dist -regex '.*/podman-[0-9][0-9\.]*.tar.gz' -print)
test-release:
	twine upload --verbose -r testpypi dist/*whl $(SOURCE)
	# pip install -i https://test.pypi.org/simple/ podman

.PHONY: release
release: SOURCE = $(shell find dist -regex '.*/podman-[0-9][0-9\.]*.tar.gz' -print)
release:
	twine upload --verbose dist/*whl $(SOURCE)
	# pip install podman

.PHONY: docs
docs:
	mkdir -p build/docs/source
	cp -R docs/source/* build/docs/source
	sphinx-apidoc --separate --no-toc --force --templatedir build/docs/source/_templates/apidoc \
		-o build/docs/source \
		podman podman/tests
	sphinx-build build/docs/source build/html

# .PHONY: install
HEAD ?= HEAD
# install:
# 	$(PYTHON) setup.py install --root ${DESTDIR}

# .PHONY: upload
# upload: clean
# 	PODMAN_VERSION=$(PODMAN_VERSION) $(PYTHON) setup.py sdist bdist_wheel
# 	twine check dist/*
# 	twine upload --verbose dist/*
# 	twine upload --verbose dist/*

.PHONY: clobber
clobber: uninstall clean

.PHONY: uninstall
uninstall:
	$(PYTHON) -m pip uninstall --yes podman ||:

.PHONY: clean
clean:
	rm -rf podman_py.egg-info dist build/*
	find . -depth -name __pycache__ -exec rm -rf {} \;
	find . -depth -name \*.pyc -exec rm -f {} \;
	$(PYTHON) ./setup.py clean --all

.PHONY: validate
validate: .gitvalidation lint

.PHONY: .gitvalidation
.gitvalidation:
	# I have no great ideas on how to install/check for git-validation
	@echo "Validating vs commit '$(call err_if_empty,EPOCH_TEST_COMMIT)'"
	GIT_CHECK_EXCLUDE="./vendor:docs/make.bat" git-validation -run DCO,short-subject,dangling-whitespace -range $(EPOCH_TEST_COMMIT)..$(HEAD)
