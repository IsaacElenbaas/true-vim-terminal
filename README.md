# TrueVimTerminal
## About
TrueVimTerminal is a set of vim and zsh (with bash planned) plugins which allow you to use your terminal almost as though it were a normal buffer in vim.

Demo (TODO)

You can also run a demo by cloning, setting `TVT_ESCAPE` in `true-vim-terminal.plugin.zsh`, and running `demo` (which also accepts `-c`)

## Usage
1. Include each plugin in their respective `.*rc`
2. Set `TVT_ESCAPE` in your zshrc, your 'escape to vim' bind

	Don't make it `^[` or you will have issues with special characters

	Check whether your desired combo (if you're not using a sequence) will work using `showkey -a`

	Through `.Xresources` one can use combos otherwise unavailable, as in this example mapping `^^[` to `^K`:
```
*VT100*translations: #override \n\
    Ctrl <Key>Escape: string(0x0b)
```
3. Set `g:TrueVimTerm_prompt_regex` in your vimrc

	It is important to get this as specific as possible, having one too generic will cause very odd issues

	The default is just `^\S*\s*`, which is really hardly good enough for the demo
4. Optionally, set `TVT_DELIMITER`, `TVT_DRAW_SLEEP`, and/or `TVT_REDRAW_SLEEP` (see `true-vim-terminal.plugin.zsh`)
5. Set `shell` as your shell
	I just make all of my window manager keybinds use `xterm -e "shell -c \"commands\""` so that I can manually launch xterm and still get to a working shell when I break things
