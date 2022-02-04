# TrueVimTerminal
## About
TrueVimTerminal is a set of vim and zsh (with bash planned) plugins which allow you to use your terminal almost as though it were a normal buffer in vim.

Demo (TODO)

You can also run a demo by cloning, setting `TVT_ESCAPE` (see below) in `true-vim-terminal.plugin.zsh`, and running `demo` (which also accepts `-c`)
## Usage
1. Include each plugin in their respective `.*rc`
2. Set `TVT_ESCAPE` in your `.zshrc`, which determines your 'escape to vim' bind

	Don't make it `^[` or you will have issues with special characters

	Don't make it `^W`, vim hates passing it through for terminal use already and using it as your escape character breaks things

	If you are not using a sequence, check whether your desired combo will work using `showkey -a`

	Through `.Xresources` one can use combos otherwise unavailable, as in this example mapping `^^[` (which doesn't exist) to `^K`:
```
*VT100*translations: #override \n\
    Ctrl <Key>Escape: string(0x0b)
```
3. Set `g:TrueVimTerm_prompt_regex` in your `.vimrc`, which is a vim regular expression to match your prompt

	It is important to get this as specific as possible, having one too generic will cause very odd issues

	The default is just `^\S*\s*`, which is really hardly good enough for the demo
4. Set `shell` as your shell

	I just make all of my window manager keybinds use `xterm -e "shell -c \"commands\""` so that I can manually launch xterm and still get to a working shell when I break things
## Customization
### zsh
* `TVT_DELIMITER`: The delimiter used when vim is sending text modification commands to zsh

	ASCII decimal code, defaults to 31 (unit separator)
* `TVT_DRAW_SLEEP`: How long to wait for zsh to draw

	In 10ms increments, defaults to 1
* `TVT_REDRAW_SLEEP`: How long to wait for vim to catch redraws

	In 10ms increments, defaults to 1
### vim
* `TrueVimTerm_Start(buf, new)`: Overloadable function to set buffer variables for a better terminal experience and create buffer mappings

	`buf` contains the buffer number and `new` is a boolean representing whether the terminal buffer was just created (if it wasn't, normal mode mappings and most settings won't need to be re-set)
* `TrueVimTerm_DefaultBinds()`: Should be called in `TrueVimTerm_Start` (unless you don't want the default vim binds)
### Paste
There are two functions, `Tapi_TVT_Paste` and `Tapi_TVT_NoPaste`, which are used to enter an entirely passthrough state. The former removes all terminal insert mode mappings, and the latter calls `TrueVimTerm_Start` with `new=0`. These are automatically called upon entering a nested vim session.

Here are some handy aliases to allow you to call them manually:
```
alias Paste='printf "\033]51;[\"call\",\"Tapi_TVT_Paste\",[]]\007"'
alias NoPaste='printf "\033]51;[\"call\",\"Tapi_TVT_NoPaste\",[]]\007"'
```
