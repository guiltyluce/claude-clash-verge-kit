.PHONY: check network-check

check:
	scripts/check.sh

network-check:
	RUN_NETWORK_CHECK=1 scripts/check.sh

