phony: test vhs

test:
	nvim --headless --cleanup -u tests/init.vim -c "PlenaryBustedDirectory tests {minimal_init = 'tests/init.vim'}"


vhs:
	cd media && vhs g0testcurrent.tape && vhs g0addtags.tape


