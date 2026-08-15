.PHONY: install validate lint check status rotate save enable disable

install:
	./install.sh

validate:
	omarchy plugin validate .

lint:
	./scripts/lint-qml
	bash -n install.sh uninstall.sh scripts/*.sh scripts/lib/*.sh scripts/control scripts/rotate-background scripts/save-current cli/purrpaper

check: validate lint

status:
	./cli/purrpaper status

rotate:
	./cli/purrpaper rotate

save:
	./cli/purrpaper save

enable:
	./cli/purrpaper enable

disable:
	./cli/purrpaper disable
