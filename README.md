# TrueVimTerminal
## About
TrueVimTerminal is a set of vim and bash/zsh plugins which allow you to use your terminal almost as though it were a normal buffer in vim.

Demo (TODO)

You can also run a demo by cloning and running `demo` (which also accepts `-c`)
## Usage
1. Include each plugin in their respective `.*rc`
2. Set `TVT_ESCAPE` in your `.{ba,z}shrc`, which determines your 'escape to vim' bind  
	Don't make it `^[` or you will have issues with special characters  
		Things *beginning* with `^[`, however, such as function keys, should be fine though  
	Don't make it `^W`, vim dislikes passing it through for terminal use already and using it as your escape character may break things  
	If you are not using a sequence, check whether your desired combo will work using `showkey -a`  
		You may have to `set bind-tty-special-chars off` in your `.inputrc` for some combos  
		`util/get_usable` should print a list of usable combos with the above set  
	Through `.Xresources` one can use combos otherwise unavailable, as in this example mapping `^^[` (which doesn't exist) to `^K`:
```
*VT100*translations: #override \n\
    Ctrl <Key>Escape: string(0x0b)
```
3. Set `g:TrueVimTerm_prompt_regex` in your `.vimrc`, which is a vim regular expression to match your prompt  
	It is important to get this as specific as possible, having one too generic will cause very odd issues  
	The default is just `^\S*\s*`
4. Set `shell` as your shell
	It defaults to launching `zsh` if present  
	I just make all of my window manager keybinds use `xterm -e "shell -c \"commands\""` so that I can manually launch xterm and still get to a working shell when I break things
## Customization
### bash/zsh
* `TVT_DELIMITER`: The delimiter used when vim is sending text modification commands to the shell
	ASCII decimal code, defaults to 31 (unit separator)
* `TVT_DRAW_SLEEP`: How long to wait for the shell to draw
	In 10ms increments, defaults to 1
* `TVT_REDRAW_SLEEP`: How long to wait for vim to catch redraws
	In 10ms increments, defaults to 1
### vim
* `TrueVimTerm_Start(buf, new)`: Overloadable function used to set buffer variables for a better terminal experience and create buffer mappings  
	`buf` contains the buffer number and `new` is a boolean representing whether the terminal buffer was just created (if it wasn't, normal mode mappings and most settings won't need to be re-set)
* `TrueVimTerm_Start_User(buf, new)`: Should be called in `TrueVimTerm_Start` overloads, used to define user customization without removing the defaults
* `TrueVimTerm_Mappings()`: Overloadable function used to create default mappings
* `TrueVimTerm_Mappings_User()`: Should be called in `TrueVimTerm_Start` overloads, used to define user mappings without removing the defaults
### Paste
There are two functions, `Tapi_TVT_Paste` and `Tapi_TVT_NoPaste`, which are used to enter an entirely passthrough state. The former removes all terminal job mode mappings, and the latter calls `TrueVimTerm_Start` with `new=0`. These are automatically called upon entering a nested vim session.  
Here are some handy aliases to allow you to call them manually:
```
alias Paste='printf "\033]51;[\"call\",\"Tapi_TVT_Paste\",[]]\007"'
alias NoPaste='printf "\033]51;[\"call\",\"Tapi_TVT_NoPaste\",[]]\007"'
```
