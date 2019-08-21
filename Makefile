.PHONY: all vital test themis docker_themis html pip_install lint python_doctest clean clean-all bin ancient aspell repl circleci

PWD=$(shell pwd)

PLUGIN_NAME = iced
VITAL_MODULES = \
		Async.Promise \
		Data.Dict \
		Data.List \
		Data.String \
		Locale.Message \
		Vim.Buffer \
		Vim.BufferManager \
		Vim.Message

all: vital bin test

vital:
	\rm -rf autoload/vital*
	vim -c "Vitalize . --name=$(PLUGIN_NAME) $(VITAL_MODULES)" -c q

test: themis lint python_doctest

.vim-themis:
	git clone https://github.com/thinca/vim-themis .vim-themis
.vim-sexp:
	git clone https://github.com/guns/vim-sexp .vim-sexp

themis: .vim-themis .vim-sexp
	./.vim-themis/bin/themis

docker_themis: .vim-themis .vim-sexp
	docker run --rm -v $(PWD):/root --entrypoint './.vim-themis/bin/themis' uochan/vim:latest

docker_neovim_themis: .vim-themis .vim-sexp
	docker run --rm -v $(PWD):/mnt/volume lambdalisue/neovim-themis:latest

html: doc/vim-iced.txt
	bash scripts/html.sh

pip_install:
	sudo pip3 install -r requirements.txt

lint:
	bash scripts/lint.sh

python_doctest:
	python3 -m doctest python/bencode.py

coverage: themis
	bash scripts/coverage.sh

clean:
	\rm -rf target .vim-sexp .vim-themis

clan-all: clean
	\rm -rf autoload/vital*
	\rm -f bin/iced

bin:
	clojure -A:jackin -m iced-jackin

ancient:
	clojure -A:ancient

aspell:
	aspell -d en -W 3 -p ./.aspell.en.pws check README.adoc
	aspell -d en -W 3 -p ./.aspell.en.pws check CHANGELOG.adoc
	aspell -d en -W 3 -p ./.aspell.en.pws check doc/vim-iced.txt

repl:
	clojure -R:jackin:dev -m iced-repl

circleci: clean
	circleci build