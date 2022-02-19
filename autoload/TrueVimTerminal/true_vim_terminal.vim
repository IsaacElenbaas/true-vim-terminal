"{{{ ParseLine(line, mode)
function s:ParseLine(line, ...)
	let l:line=substitute(a:line, g:TrueVimTerm_prompt_regex, "", "")
	if a:0 == 1
		let l:visual=(a:1 == visualmode())
		let l:left=(l:visual) ? "'<" : "'["
		let l:right=(l:visual) ? "'>" : "']"
		if line(l:left) != line(l:right) || !(index([0, line(l:left)], search(g:TrueVimTerm_prompt_regex . '\%(\_.\{-}\%$\)\@<=', "cnW"))+1)
			throw "[TVT] You can't do that here."
		endif
		let l:offset=strcharlen(a:line)-strcharlen(l:line)
		let l:left=max([0, charcol(l:left)-l:offset-1])
		let l:right=charcol(l:right)-l:offset
		let l:line=substitute(l:line, '\s*$', "", "")
		return [
			\ l:offset,
			\ strcharpart(l:line, 0, l:left),
			\ strcharpart(l:line, l:left, l:right-l:left),
			\ strcharpart(l:line, l:right)
		\ ]
	endif
	return [strcharlen(a:line)-strcharlen(l:line), substitute(l:line, '\s*$', "", "")]
endfunc
function TrueVimTerminal#true_vim_terminal#ParseLine(line, ...)
	return call('s:ParseLine', [a:line] + a:000)
endfunction
"}}}

"{{{ default bind functions
	"{{{ c/cc/C
function TrueVimTerminal#true_vim_terminal#Change(mode)
	let l:line=s:ParseLine(getline("."), a:mode)
	call setreg(g:TrueVimTerm_register, l:line[2])
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "3" . l:line[1] . g:TrueVimTerm_delimiter .
		\ "4" . l:line[3] . g:TrueVimTerm_delimiter .
		\ "0" . g:TrueVimTerm_delimiter
	\ )
endfunc
	"}}}

	"{{{ d/dd/D
function TrueVimTerminal#true_vim_terminal#Delete(mode)
	let l:line=s:ParseLine(getline("."), a:mode)
	if g:TrueVimTerm_register != "_"
		call setreg("-", l:line[2])
		call setreg(g:TrueVimTerm_register, l:line[2])
	endif
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "3" . l:line[1] . g:TrueVimTerm_delimiter .
		\ "4" . l:line[3] . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
endfunc
	"}}}

	"{{{ p/P
function TrueVimTerminal#true_vim_terminal#Paste_after(mode)
	let l:visual=(a:mode == visualmode())
	if l:visual
		let l:line=s:ParseLine(getline("."), a:mode)
	endif
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "2" . (charcol(".")-s:ParseLine(getline("."))[0]) . g:TrueVimTerm_delimiter .
		\ ((l:visual) ? (
			\ "3" . l:line[1] . g:TrueVimTerm_delimiter .
			\ "4" . l:line[3] . g:TrueVimTerm_delimiter
		\ ) : "") .
		\ "5" . substitute(getreg(g:TrueVimTerm_register), '\s*\n', "", "g") . g:TrueVimTerm_delimiter .
		\ "2" . "-1" . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
	if l:visual
		call setreg(g:TrueVimTerm_register, l:line[2])
	endif
endfunc
function TrueVimTerminal#true_vim_terminal#Paste_before(mode)
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "2" . (charcol(".")-s:ParseLine(getline("."))[0]-1) . g:TrueVimTerm_delimiter .
		\ "5" . substitute(getreg(g:TrueVimTerm_register), '\s*\n', "", "g") . g:TrueVimTerm_delimiter .
		\ "2" . "-1" . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
endfunc
	"}}}

	"{{{ r/R
function TrueVimTerminal#true_vim_terminal#Replace(mode, count)
	let l:line=s:ParseLine(getline("."))
	let l:key=getchar()
	if type(l:key) != 0
		" TODO: emulate replace mode mappings
		return
	endif
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "2" . (charcol(".")-l:line[0]) . g:TrueVimTerm_delimiter .
		\ "3" . l:line[1][0:charcol(".")-l:line[0]-2] . repeat(nr2char(l:key), max([1, a:count])) . g:TrueVimTerm_delimiter .
		\ "4" . l:line[1][charcol(".")-l:line[0]-1+max([1, a:count]):] . g:TrueVimTerm_delimiter .
		\ "2" . "-1" . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
endfunc
	"}}}

	"{{{ s/S
function TrueVimTerminal#true_vim_terminal#Substitute(count)
	call feedkeys("v" . ((a:count > 1) ? (a:count-1) . "l" : "") . "\<Esc>", "nx")
	let l:line=s:ParseLine(getline("."), visualmode())
	call setreg(g:TrueVimTerm_register, l:line[2])
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "3" . l:line[1] . g:TrueVimTerm_delimiter .
		\ "4" . l:line[3] . g:TrueVimTerm_delimiter .
		\ "0" . g:TrueVimTerm_delimiter
	\ )
endfunc
	"}}}

	"{{{ x/X
function TrueVimTerminal#true_vim_terminal#XDelete(count)
	call feedkeys("v" . ((a:count > 1) ? (a:count-1) . "l" : "") . "\<Esc>", "nx")
	let l:line=s:ParseLine(getline("."), visualmode())
	call setreg(g:TrueVimTerm_register, l:line[2])
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "3" . l:line[1] . g:TrueVimTerm_delimiter .
		\ "4" . l:line[3] . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
endfunc
	"}}}

	"{{{ y/yy
function TrueVimTerminal#true_vim_terminal#Yank(mode)
	let l:visual=(a:mode == visualmode())
	let l:left=(l:visual) ? "'<" : "'["
	let l:right=(l:visual) ? "'>" : "']"
	if line(l:left) != line(l:right) || line(l:left) != search(g:TrueVimTerm_prompt_regex . '\%(\_.\{-}\%$\)\@<=', "cnW")+1
		" I can't find a better way to get this text
		call feedkeys("`" . l:left[1] . visualmode() . "`" . l:right[1] . "\"" . g:TrueVimTerm_register . "y", "nx")
		if col(l:left) == 1
			call setreg(g:TrueVimTerm_register, substitute(getreg(g:TrueVimTerm_register), g:TrueVimTerm_prompt_regex, "", ""))
		endif
		return
	endif
	let l:line=s:ParseLine(getline("."), a:mode)
	if g:TrueVimTerm_register != "_"
		call setreg("0", l:line[2])
		call setreg(g:TrueVimTerm_register, l:line[2])
	endif
endfunc
	"}}}
"}}}
