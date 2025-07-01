set smartindent
set tabstop=2
set number
colorscheme desert

:set number

:augroup numbertoggle
:	autocmd!
:	autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
: 	autocmd BufLeave,FocusLost,InsertEnter,WinLeave	  * if &nu		    | set nornu | endif
:augroup END

" Start NERDTree and put the cursor back in the other window.
" autocmd VimEnter * NERDTree | wincmd p

" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

let g:NERDTreeGitStatusUseNerdFonts = 1 " you should install nerdfonts by yourself. default: 0
let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0

filetype plugin indent on
" show existing tab with 4 spaces width
set autoindent
set tabstop=2
" when indenting with '>', use 4 spaces width
set shiftwidth=2
set smarttab

" Key remaps
inoremap { {}<Esc>i
inoremap {<BS> <Esc>i
inoremap {<CR> {<CR><Tab><CR>}<Esc>ki<Tab>
inoremap {} {}
inoremap ( ()<Esc>i
inoremap (<BS> <Esc>i
inoremap () ()
inoremap [ []<Esc>i
inoremap [<BS> <Esc>i
inoremap [] []
inoremap " ""<Esc>i
inoremap "<BS> <Esc>i
inoremap "" ""
inoremap ` ``<Esc>i
inoremap `<BS> <Esc>i
inoremap `` ``

inoremap <S-Tab> <C-d>
inoremap <expr> <Tab> search('\%#[]>)}]', 'n') ? '<Right>' : '<Tab>'
imap <C-BS> <C-W>

" Fix tmux issues in vim
if &term =~ '^screen'
	" tmux will send xterm-style keys when its xterm-keys option is on
	execute "set <xUp>=\e[1;*A"
	execute "set <xDown>=\e[1;*B"
	execute "set <xRight>=\e[1;*C"
	execute "set <xLeft>=\e[1;*D"
endif"]""]""]""]"
