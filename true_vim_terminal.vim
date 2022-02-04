if !exists("g:TrueVimTerm_prompt_regex")
	let g:TrueVimTerm_prompt_regex='^\S*\s*'
endif

"{{{ Tapi_TVT_Delimiter()
function Tapi_TVT_Delimiter(bufnum, arglist)
	let g:TrueVimTerm_delimiter=nr2char(a:arglist[0])
endfunc
"}}}

"{{{ Tapi_TVT_Escape()
function Tapi_TVT_Escape(bufnum, arglist)
	if len(a:arglist) != 0 && a:arglist[0] != 0
		call term_wait(bufnr("%"), a:arglist[0]*10)
	endif
	call feedkeys("\<c-w>N", "n")
endfunc
"}}}

"{{{ Tapi_TVT_Feedkeys(string, mode)
"function Tapi_TVT_Feedkeys(bufnum, arglist)
"	exec "call feedkeys(\"" . a:arglist[0] . "\", \"" . a:arglist[1] . "\")"
"endfunc
"}}}

	"{{{ Tapi_TVT_Send(0, [t_ts, title, t_fs])
function Tapi_TVT_Send(bufnum, arglist)
	if a:arglist[0]
		if match(a:arglist, '|\|"') == -1
			execute 'let a:arglist[1]="' . a:arglist[1] . '"'
			execute 'let a:arglist[2]="' . a:arglist[2] . '"'
			execute 'let a:arglist[3]="' . a:arglist[3] . '"'
		else
			echo "Illegal characters! Improve Tapi_TVT_Send to make this sequence work."
			return
		endif
	endif
	let l:t_ts=&t_ts
	let l:t_fs=&t_fs
	let l:titlestring=&titlestring
	let l:title=&title
	execute "set t_ts=" . a:arglist[1] . " t_fs=" . a:arglist[3] . " titlestring=" . a:arglist[2] | set title | redraw
	execute "set t_ts=" . l:t_ts . " t_fs=" . l:t_fs . " titlestring=" . l:titlestring
	if l:title
		redraw
	else
		set notitle
	endif
endfunc
	"}}}

"{{{ ParseLine(line, mode)
function s:ParseLine(line, ...)
	let l:line=substitute(a:line, g:TrueVimTerm_prompt_regex, "", "")
	if a:0 == 1
		let l:visual=(a:1 == visualmode())
		let l:left=(l:visual) ? "'<" : "'["
		let l:right=(l:visual) ? "'>" : "']"
		if line(l:left) != line(l:right) || line(l:left) != search(g:TrueVimTerm_prompt_regex . '\%(\_.\{-}\%$\)\@<=', "cnW")+1
			throw "[TVT] You can't do that here."
		endif
		let l:offset=len(a:line)-len(l:line)
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
	return [len(a:line)-len(l:line), substitute(l:line, '\s*$', "", "")]
endfunc
"}}}

"{{{ default bind functions
	"{{{ a/A
nnoremap <silent> <script> <Plug>TrueVimTerm_a :<c-u>call term_sendkeys(bufnr("%"), "2" . (charcol(".")-<SID>ParseLine(getline("."))[0]) . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
nnoremap <silent> <script> <Plug>TrueVimTerm_A :<c-u>call term_sendkeys(bufnr("%"), "2" . strcharlen(<SID>ParseLine(getline("."))[1]) . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
map <Plug>(TrueVimTerm_a) <Plug>TrueVimTerm_a
map <Plug>(TrueVimTerm_A) <Plug>TrueVimTerm_A
	"}}}

	"{{{ c/cc/C
function s:Change(mode)
	let l:line=s:ParseLine(getline("."), a:mode)
	call setreg(g:TrueVimTerm_register, l:line[2])
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "3" . l:line[1] . g:TrueVimTerm_delimiter .
		\ "4" . l:line[3] . g:TrueVimTerm_delimiter .
		\ "0" . g:TrueVimTerm_delimiter
	\ )
endfunc
nnoremap <silent> <script> <Plug>TrueVimTerm_c :<c-u>let g:TrueVimTerm_register=v:register<Bar>set opfunc=<SID>Change<CR>g@
xnoremap <silent> <script> <Plug>TrueVimTerm_c :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Change(visualmode())<CR>
map <Plug>(TrueVimTerm_c) <Plug>TrueVimTerm_c
	"}}}

	"{{{ d/dd/D
function s:Delete(mode)
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
nnoremap <silent> <script> <Plug>TrueVimTerm_d :<c-u>let g:TrueVimTerm_register=v:register<Bar>set opfunc=<SID>Delete<CR>g@
xnoremap <silent> <script> <Plug>TrueVimTerm_d :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Delete(visualmode())<CR>
map <Plug>(TrueVimTerm_d) <Plug>TrueVimTerm_d
	"}}}

	"{{{ i/I
nnoremap <silent> <script> <Plug>TrueVimTerm_i :<c-u>call term_sendkeys(bufnr("%"), "2" . (charcol(".")-<SID>ParseLine(getline("."))[0]-1) . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
nnoremap <silent> <script> <Plug>TrueVimTerm_I :<c-u>call term_sendkeys(bufnr("%"), "2" . 0 . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
map <Plug>(TrueVimTerm_i) <Plug>TrueVimTerm_i
map <Plug>(TrueVimTerm_I) <Plug>TrueVimTerm_I
	"}}}

	"{{{ p/P
function s:Paste_after(mode)
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
function s:Paste_before(mode)
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "2" . (charcol(".")-s:ParseLine(getline("."))[0]-1) . g:TrueVimTerm_delimiter .
		\ "5" . substitute(getreg(g:TrueVimTerm_register), '\s*\n', "", "g") . g:TrueVimTerm_delimiter .
		\ "2" . "-1" . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
endfunc
nnoremap <silent> <script> <Plug>TrueVimTerm_p :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Paste_after("char")<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_p :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Paste_after(visualmode())<CR>
map <Plug>(TrueVimTerm_p) <Plug>TrueVimTerm_p
nnoremap <silent> <script> <Plug>TrueVimTerm_P :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Paste_before("char")<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_P <Esc><Esc>
map <Plug>(TrueVimTerm_P) <Plug>TrueVimTerm_P
	"}}}

	"{{{ r/R
function s:Replace(mode)
	let l:line=s:ParseLine(getline("."))
	let l:key=getchar()
	if type(l:key) != 0
		" TODO: emulate replace mode mappings
		return
	endif
	call feedkeys("i", "nx")
	call term_sendkeys(bufnr("%"),
		\ "2" . (charcol(".")-l:line[0]) . g:TrueVimTerm_delimiter .
		\ "3" . l:line[1][0:charcol(".")-l:line[0]-2] . nr2char(l:key) . g:TrueVimTerm_delimiter .
		\ "1" . g:TrueVimTerm_delimiter
	\ )
endfunc
nnoremap <silent> <script> <Plug>TrueVimTerm_r :<c-u>call <SID>Replace("char")<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_r :<c-u>call <SID>Replace(visualmode())<CR>
map <Plug>(TrueVimTerm_r) <Plug>TrueVimTerm_r
" TODO
"nnoremap <silent> <script> <Plug>TrueVimTerm_R :<c-u>call <SID>Replace("recurse")<CR>
"map <Plug>(TrueVimTerm_R) <Plug>TrueVimTerm_R
	"}}}

	"{{{ s/S
function s:Substitute(count)
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
nnoremap <silent> <script> <Plug>TrueVimTerm_s :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Substitute(v:count)<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_s :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Change(visualmode())<CR>
map <Plug>(TrueVimTerm_s) <Plug>TrueVimTerm_s
nnoremap <silent> <script> <Plug>TrueVimTerm_S <Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Change(visualmode())<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_S <Esc><Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Change(visualmode())<CR>
map <Plug>(TrueVimTerm_S) <Plug>TrueVimTerm_S
	"}}}

	"{{{ x/X
function s:XDelete(count)
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
nnoremap <silent> <script> <Plug>TrueVimTerm_x :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>XDelete(v:count)<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_x :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Delete(visualmode())<CR>
map <Plug>(TrueVimTerm_x) <Plug>TrueVimTerm_x
nnoremap <silent> <script> <Plug>TrueVimTerm_X <Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Delete(visualmode())<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_X <Esc><Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Delete(visualmode())<CR>
map <Plug>(TrueVimTerm_X) <Plug>TrueVimTerm_X
	"}}}

	"{{{ y/yy
function s:Yank(mode)
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
nnoremap <silent> <script> <Plug>TrueVimTerm_y :<c-u>let g:TrueVimTerm_register=v:register<Bar>set opfunc=<SID>Yank<CR>g@
xnoremap <silent> <script> <Plug>TrueVimTerm_y :<c-u>let g:TrueVimTerm_register=v:register<Bar>call <SID>Yank(visualmode())<CR>
map <Plug>(TrueVimTerm_y) <Plug>TrueVimTerm_y
	"}}}
"}}}

"{{{ TrueVimTerm_Start(new)
try
	function TrueVimTerm_Start(buf, new)
		tnoremap <buffer> <expr> <c-w> (term_sendkeys(bufnr("%"), "\<c-w>"))?"":""

	"{{{ reserve columns
		" reserve columns for numbers, two for signs, and onemore
		" may be removed after #8365
		execute "setlocal termwinsize=0x" . (winwidth("%")-(
			\ ((&number || &relativenumber) ? min([2, &numberwidth]) : 0)+
			\ 2+
			\ ((match(&virtualedit, 'onemore') != -1) ? 1 : 0)
		\ ))
		augroup TrueVimTerm_Resize
			autocmd!
			autocmd VimResized * execute "setlocal termwinsize=0x" . (winwidth("%")-(
				\ ((&number || &relativenumber) ? min([2, &numberwidth]) : 0)+
				\ 2+
				\ ((match(&virtualedit, 'onemore') != -1) ? 1 : 0)
			\ ))
		augroup END
	"}}}

		" no tmaps so only if new
		if a:new
			call TrueVimTerm_DefaultBinds()
		endif
		try
			call TrueVimTerm_Binds()
		catch /^.*E117:.*/
		endtry
	endfunc
catch /^.*E122:.*/
endtry
"}}}

"{{{ TrueVimTerm_DefaultBinds()
function! TrueVimTerm_DefaultBinds()
	setlocal termwinkey=

	"{{{ a/A
	nmap <buffer> a <Plug>TrueVimTerm_a
	nmap <buffer> A <Plug>TrueVimTerm_A
	"}}}

	"{{{ c/cc/C
	nmap <buffer> c <Plug>TrueVimTerm_c
	xmap <buffer> c <Plug>TrueVimTerm_c
	nmap <buffer> <expr> cc "<Esc>0\"" . v:register . "<Plug>(TrueVimTerm_c)$"
	nmap <buffer> C <Plug>(TrueVimTerm_c)$
	"}}}

	"{{{ d/dd/D
	nmap <buffer> d <Plug>TrueVimTerm_d
	xmap <buffer> d <Plug>TrueVimTerm_d
	nmap <buffer> <expr> dd "<Esc>0\"" . v:register . "<Plug>(TrueVimTerm_d)$"
	nmap <buffer> D <Plug>(TrueVimTerm_d)$
	"}}}

	"{{{ i/I
	nmap <buffer> i <Plug>TrueVimTerm_i
	nmap <buffer> I <Plug>TrueVimTerm_I
	"}}}

	"{{{ p/P
	nmap <buffer> p <Plug>TrueVimTerm_p
	xmap <buffer> p <Plug>TrueVimTerm_p
	nmap <buffer> P <Plug>TrueVimTerm_P
	xmap <buffer> P <Plug>TrueVimTerm_P
	"}}}

	"{{{ r/R
	nmap <buffer> r <Plug>TrueVimTerm_r
	xmap <buffer> r <Plug>TrueVimTerm_r
	" TODO
	"nmap <buffer> R <Plug>TrueVimTerm_R
	"}}}

	"{{{ s/S
	nmap <buffer> s <Plug>TrueVimTerm_s
	xmap <buffer> s <Plug>TrueVimTerm_s
	nmap <buffer> S <Plug>TrueVimTerm_S
	xmap <buffer> S <Plug>TrueVimTerm_S
	"}}}

	"{{{ x/X
	nmap <buffer> x <Plug>TrueVimTerm_x
	xmap <buffer> x <Plug>TrueVimTerm_x
	nmap <buffer> X <Plug>TrueVimTerm_X
	xmap <buffer> X <Plug>TrueVimTerm_X
	"}}}

	"{{{ y/yy
	nmap <buffer> y <Plug>TrueVimTerm_y
	nmap <buffer> <expr> yy "<Esc>0\"" . v:register . "<Plug>(TrueVimTerm_y)$"
	xmap <buffer> y <Plug>TrueVimTerm_y
	"}}}
	" RECOMMENDED: nmap Y <Plug>(TrueVimTerm_y)$
endfunc
"}}}

"{{{ Tapi_TVT_Paste()
function! Tapi_TVT_Paste(bufnum, arglist)
	tnoremap <buffer> <expr> <c-w> (term_sendkeys(bufnr("%"), "\<c-w>"))?"":""
	" may be removed after #8365
	set termwinsize=
	autocmd! TrueVimTerm_Resize

	"{{{ remove all terminal mappings
	try
		let l:maps="\n" . substitute(substitute(execute("tmap"), '\nt\s*', '\n', "g"), '^\n*', '', "")
		let l:nl=0
		while 1
			let l:sp=stridx(l:maps, " ", l:nl)
			try
				execute "tunmap " . substitute(strcharpart(l:maps, l:nl+1, l:sp-l:nl-1), '|', '<bar>', "g")
			catch /^.*E31:.*/
			endtry
			let l:nl=stridx(l:maps, "\n", l:sp)
			if l:nl == -1
				break
			endif
		endwhile
	catch /^.*E31:.*/
	endtry
	"}}}
endfunc
"}}}

"{{{ Tapi_TVT_NoPaste()
function! Tapi_TVT_NoPaste(bufnum, arglist)
	call TrueVimTerm_Start(0)
endfunc
"}}}

augroup TrueVimTerm
	autocmd!
	autocmd TerminalOpen * call TrueVimTerm_Start(expand("<abuf>"), 1)
	autocmd VimEnter * call Tapi_TVT_Send(0, [0, "\033]51;", '["call","Tapi_TVT_Paste",[]]',    "\007"])
	autocmd VimLeave * call Tapi_TVT_Send(0, [0, "\033]51;", '["call","Tapi_TVT_NoPaste",[]]', "\007"])
augroup END
