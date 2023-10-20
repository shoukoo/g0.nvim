phony: test

test:
	nvim --headless --cleanup -u tests/init.vim -c "PlenaryBustedDirectory tests {minimal_init = 'tests/init.vim'}"

