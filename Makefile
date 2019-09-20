.PHONY: clean prepare wheel install dist check_dist upload dev_tools bump release

NO_COLOR = \x1b[0m
OK_COLOR = \x1b[32;01m
ERROR_COLOR = \x1b[31;01m

PYCACHE := $(shell find . -name '__pycache__')
EGGS := $(wildcard *.egg-info)
CURRENT_VERSION := $(shell awk '/current_version/ {print $$3}' .bumpversion.cfg)

clean:
	@echo "$(OK_COLOR)=> Cleaning$(NO_COLOR)"
	echo egg $(EGGS)
	@rm -fr build dist $(EGGS) $(PYCACHE)

prepare: clean
	git add .
	git status
	git commit -m "cleanup before release"

# Version commands

bump:
ifdef part
ifdef version
	bumpversion --new-version $(version) $(part) && grep current .bumpversion.cfg
else
	bumpversion $(part) && grep current .bumpversion.cfg
endif
else
	@echo "$(ERROR_COLOR)Provide part=major|minor|patch|release|build and optionally version=x.y.z...$(NO_COLOR)"
	exit 1
endif

# Dist commands

dist:
	@python setup.py sdist bdist_wheel

release:
	git add .
	git status
	git commit -m "Latest release: $(CURRENT_VERSION)"
	git tag -a v$(CURRENT_VERSION) -m "Latest release: $(CURRENT_VERSION)"

install:
	@echo "$(OK_COLOR)=> Installing databrickslabs_jupyterlab$(NO_COLOR)"
	@pip install --upgrade .

check_dist:
	@twine check dist/*

upload:
	@twine upload dist/*

# dev tools

dev_tools:
	pip install twine bumpversion yapf pylint pyYaml
