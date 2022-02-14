if !exists("g:TrueVimTerm_prompt_regex")
	let g:TrueVimTerm_prompt_regex='^\S*\s*'
endif
if $TVT_DEMO != "" || $TVT_TEST != ""
	let g:TrueVimTerm_prompt_regex='^\[TVT[^\]]*\].\s'
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
	if mode() == "t"
		call feedkeys("\<c-w>N", "n")
	endif
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
			throw "[TVT] Illegal characters! Improve Tapi_TVT_Send to make this sequence work."
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

"{{{ default bind plugin mappings
	"{{{ a/A
nnoremap <silent> <script> <Plug>TrueVimTerm_a :<c-u>call term_sendkeys(bufnr("%"), "2" . (charcol(".")-TrueVimTerminal#true_vim_terminal#ParseLine(getline("."))[0]) . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
nnoremap <silent> <script> <Plug>TrueVimTerm_A :<c-u>call term_sendkeys(bufnr("%"), "2" . strcharlen(TrueVimTerminal#true_vim_terminal#ParseLine(getline("."))[1]) . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
map <Plug>(TrueVimTerm_a) <Plug>TrueVimTerm_a
map <Plug>(TrueVimTerm_A) <Plug>TrueVimTerm_A
	"}}}

	"{{{ c/cc/C
nnoremap <silent> <script> <Plug>TrueVimTerm_c :<c-u>let g:TrueVimTerm_register=v:register<Bar>set opfunc=TrueVimTerminal#true_vim_terminal#Change<CR>g@
xnoremap <silent> <script> <Plug>TrueVimTerm_c :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Change(visualmode())<CR>
map <Plug>(TrueVimTerm_c) <Plug>TrueVimTerm_c
nmap <expr> <Plug>TrueVimTerm_cc "<Esc>0\"" . v:register . "<Plug>(TrueVimTerm_c)$"
map <Plug>(TrueVimTerm_cc) <Plug>TrueVimTerm_cc
nmap <silent> <Plug>TrueVimTerm_C <Plug>(TrueVimTerm_c)$
map <Plug>(TrueVimTerm_C) <Plug>TrueVimTerm_C
	"}}}

	"{{{ d/dd/D
nnoremap <silent> <script> <Plug>TrueVimTerm_d :<c-u>let g:TrueVimTerm_register=v:register<Bar>set opfunc=TrueVimTerminal#true_vim_terminal#Delete<CR>g@
xnoremap <silent> <script> <Plug>TrueVimTerm_d :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Delete(visualmode())<CR>
map <Plug>(TrueVimTerm_d) <Plug>TrueVimTerm_d
nmap <expr> <Plug>TrueVimTerm_dd "<Esc>0\"" . v:register . "<Plug>(TrueVimTerm_d)$"
map <Plug>(TrueVimTerm_dd) <Plug>TrueVimTerm_dd
nmap <silent> <Plug>TrueVimTerm_D <Plug>(TrueVimTerm_d)$
map <Plug>(TrueVimTerm_D) <Plug>TrueVimTerm_D
	"}}}

	"{{{ i/I
nnoremap <silent> <script> <Plug>TrueVimTerm_i :<c-u>call term_sendkeys(bufnr("%"), "2" . (charcol(".")-TrueVimTerminal#true_vim_terminal#ParseLine(getline("."))[0]-1) . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
nnoremap <silent> <script> <Plug>TrueVimTerm_I :<c-u>call term_sendkeys(bufnr("%"), "2" . 0 . g:TrueVimTerm_delimiter . "0" . g:TrueVimTerm_delimiter)<CR>i
map <Plug>(TrueVimTerm_i) <Plug>TrueVimTerm_i
map <Plug>(TrueVimTerm_I) <Plug>TrueVimTerm_I
	"}}}

	"{{{ p/P
nnoremap <silent> <script> <Plug>TrueVimTerm_p :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Paste_after("char")<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_p :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Paste_after(visualmode())<CR>
map <Plug>(TrueVimTerm_p) <Plug>TrueVimTerm_p
nnoremap <silent> <script> <Plug>TrueVimTerm_P :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Paste_before("char")<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_P <Esc><Esc>
map <Plug>(TrueVimTerm_P) <Plug>TrueVimTerm_P
	"}}}

	"{{{ r/R
nnoremap <silent> <script> <Plug>TrueVimTerm_r :<c-u>call TrueVimTerminal#true_vim_terminal#Replace("char",v:count)<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_r :<c-u>call TrueVimTerminal#true_vim_terminal#Replace(visualmode(),v:count)<CR>
map <Plug>(TrueVimTerm_r) <Plug>TrueVimTerm_r
" TODO
"nnoremap <silent> <script> <Plug>TrueVimTerm_R :<c-u>call TrueVimTerminal#true_vim_terminal#Replace("recurse")<CR>
"map <Plug>(TrueVimTerm_R) <Plug>TrueVimTerm_R
	"}}}

	"{{{ s/S
nnoremap <silent> <script> <Plug>TrueVimTerm_s :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Substitute(v:count)<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_s :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Change(visualmode())<CR>
map <Plug>(TrueVimTerm_s) <Plug>TrueVimTerm_s
nnoremap <silent> <script> <Plug>TrueVimTerm_S <Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Change(visualmode())<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_S <Esc><Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Change(visualmode())<CR>
map <Plug>(TrueVimTerm_S) <Plug>TrueVimTerm_S
	"}}}

	"{{{ x/X
nnoremap <silent> <script> <Plug>TrueVimTerm_x :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#XDelete(v:count)<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_x :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Delete(visualmode())<CR>
map <Plug>(TrueVimTerm_x) <Plug>TrueVimTerm_x
nnoremap <silent> <script> <Plug>TrueVimTerm_X <Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Delete(visualmode())<CR>
xnoremap <silent> <script> <Plug>TrueVimTerm_X <Esc><Esc>0v$:<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Delete(visualmode())<CR>
map <Plug>(TrueVimTerm_X) <Plug>TrueVimTerm_X
	"}}}

	"{{{ y/yy
nnoremap <silent> <script> <Plug>TrueVimTerm_y :<c-u>let g:TrueVimTerm_register=v:register<Bar>set opfunc=TrueVimTerminal#true_vim_terminal#Yank<CR>g@
xnoremap <silent> <script> <Plug>TrueVimTerm_y :<c-u>let g:TrueVimTerm_register=v:register<Bar>call TrueVimTerminal#true_vim_terminal#Yank(visualmode())<CR>
map <Plug>(TrueVimTerm_y) <Plug>TrueVimTerm_y
nmap <expr> <Plug>TrueVimTerm_yy "<Esc>0\"" . v:register . "<Plug>(TrueVimTerm_y)$"
map <Plug>(TrueVimTerm_yy) <Plug>TrueVimTerm_yy
	"}}}
"}}}

"{{{ TrueVimTerm_Start(new)
try
	function TrueVimTerm_Start(buf, new)
		tnoremap <buffer> <expr> <c-w> (term_sendkeys(bufnr("%"), "\<c-w>"))?"":""

	"{{{ reserve columns
		" reserve columns for numbers, two for signs, and onemore
		" may be removed after #8365
		execute "setlocal termwinsize=0x" . (winwidth(bufwinid(a:buf))-(
			\ ((&number || &relativenumber) ? min([2, &numberwidth]) : 0)+
			\ 2+
			\ ((match(&virtualedit, 'onemore') != -1) ? 1 : 0)
		\ ))
		execute "augroup TrueVimTerm_Resize" . a:buf . " | " .
			\ "autocmd!" . " | " .
			\ "autocmd VimResized * execute \"setlocal termwinsize=0x\" . (winwidth(bufwinid(" . a:buf . "))-(" .
				\ "((&number || &relativenumber) ? min([2, &numberwidth]) : 0)+" .
				\ "2+" .
				\ "((match(&virtualedit, 'onemore') != -1) ? 1 : 0)" .
			\ "))"
		augroup END"
	"}}}

		" no tmaps so only if new
		if a:new
			call TrueVimTerm_Mappings()
		endif
		try
			call TrueVimTerm_Start_User(a:buf, a:new)
		catch /^.*E117:.*/
		endtry
		try
			call TrueVimTerm_Mappings_User()
		catch /^.*E117:.*/
		endtry
	endfunc
catch /^.*E122:.*/
endtry
"}}}

"{{{ TrueVimTerm_Mappings()
function! TrueVimTerm_Mappings()
	setlocal termwinkey=

	"{{{ a/A
	nmap <buffer> a <Plug>TrueVimTerm_a
	nmap <buffer> A <Plug>TrueVimTerm_A
	"}}}

	"{{{ c/cc/C
	nmap <buffer> c <Plug>TrueVimTerm_c
	xmap <buffer> c <Plug>TrueVimTerm_c
	nmap <buffer> cc <Plug>TrueVimTerm_cc
	nmap <buffer> C <Plug>TrueVimTerm_C
	"}}}

	"{{{ d/dd/D
	nmap <buffer> d <Plug>TrueVimTerm_d
	xmap <buffer> d <Plug>TrueVimTerm_d
	nmap <buffer> dd <Plug>TrueVimTerm_dd
	nmap <buffer> D <Plug>TrueVimTerm_D
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
	nmap <buffer> yy <Plug>TrueVimTerm_yy
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
	autocmd TerminalOpen * call TrueVimTerm_Start(term_list()[-1], 1)
	autocmd VimEnter * call Tapi_TVT_Send(0, [0, "\033]51;", '["call","Tapi_TVT_Paste",[]]',   "\007"])
	autocmd VimLeave * call Tapi_TVT_Send(0, [0, "\033]51;", '["call","Tapi_TVT_NoPaste",[]]', "\007"])
augroup END
