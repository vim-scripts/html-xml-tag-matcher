function! s:getword()
	let l:temp = getreg('g')
	exe 'normal "gyw'
	let l:return = getreg('g')
	call setreg('g',l:temp)
	return substitute(l:return," ",'','g')
endfunction

function!    s:getnext(tagname,dir)
	while(1)
"	call s:debug("searchin")
"	call s:debug(a:tagname)
	let l:found = searchpos(a:tagname.'\>\|'.a:tagname.'\s.*>\c','W'.a:dir)
"	call s:debug(l:found)
	if(l:found[0] == 0) 
"		call s:debug('notfound')
		return '0'
	endif
	exe 'normal h'
	call searchpos('\S','bc',line('.'))
	let l:w = s:getword()
"<div>   
"dfsdfsdfsf<div class="links"></div>
"</div>
"	call s:debug(l:w)
		if(l:w =='/' || l:w == '<' ) 
			if(l:w == '/')
				exe 'normal h'
				call searchpos('\S','bc',line('.'))
				let l:w1 = s:getword()
				if(strpart(l:w1,0,1) == '<' ) 
					break
				else 
					"call s:debug(l:w1)
					call searchpos(a:tagname.'\>\|'.a:tagname.'\s.*>\c','W'.a:dir)
					exe 'normal w'
				endif
			else
				break
			endif
		else
			if(a:dir == 'b')
				exe 'normal b'
			else
				exe 'normal w'
			endif
		endif
	endwhile
	call searchpos(a:tagname.'\>\|'.a:tagname.'\s.*>\c')
	if(a:dir =='')
		exe 'normal w'
	elseif(a:dir =='b')
		exe 'normal b'
	endif
		
	if(l:w == '/') 
		return 'close'
	elseif(l:w == '<')
		return 'open'
	endif
	return '0'
endfunction

function! s:tagmatchlite()
let l:cursorbackup = getpos('.')
let l:match = searchpos('<', 'b', line("."))
if(l:match[1]>0) 
	call cursor(line('.'),l:match[1])
	call search('\S')
	let l:tagname= s:getword()
"	call s:debug(l:tagname)
	if(l:tagname== '/')
		exe 'normal w'
		let l:tagname= s:getword()
		let l:sc = -1
		let l:dir = 'b'
	else
		let l:sc = 1
		let l:dir = ''
	endif
		let l:il = 0
		while(1)
"		call s:debug('iteration '.l:il)
		let l:temp = s:getnext(l:tagname,l:dir)
	"	call s:debug(l:temp)
	"	call s:debug(getline(line('.')))
"		call s:debug(type(l:temp))
		if(l:temp == 'open' )
			let l:sc+=1
		elseif(l:temp == 'close')
			let l:sc-=1
		elseif(l:temp=='0') 
"			call s:debug("notreallyfound")
			call setpos('.',l:cursorbackup)
			if(l:sc > 0)
				echo "Found ".l:sc." Unclosed ".l:tagname ." tags."
			elseif(l:sc < 0 )
				echo "Found ".-l:sc." extra closing ".l:tagname ." tags."
			endif
			break
		endif
"		call s:debug(l:temp)
		if(l:sc==0) 
			if(l:dir == 'b')
				call search(l:tagname.'\c')
			else
				call search(l:tagname.'\c','b')
			endif
			break
		endif
"		call s:debug(l:sc)
"		call s:debug("\n")
		let l:il+=1
		if(0) 
		"call s:debug("ending")
			break
		endif
		endwhile
	endif
endfunction

command! Matchlite :call <sid>tagmatchlite()
function! s:debug(str)
	let l:currentbufnr = bufnr('%')
	if(!exists("s:debugwindow"))
		vnew
		setlocal bt=nofile
		setlocal bt=nowrite
		let s:debugwindow = bufnr('%')
		let l:thiswin = bufwinnr(s:debugwindow)
	else
		let l:thiswin = bufwinnr(s:debugwindow)
		if(l:thiswin == -1)
			vnew
			setlocal bt=nofile
			setlocal bt=nowrite
			let s:debugwindow = bufnr('%')
		endif
		exe l:thiswin . ' wincmd w'
	endif
	call append(line('$'),a:str)
	let l:thiswin = bufwinnr(l:currentbufnr)
	exe l:thiswin . ' wincmd w'
endfunction
