
source ~/.vim/neobundle.vim


" common tweaks
set nocompatible			" use improved features
set cursorline
syntax enable
set encoding=utf-8
set showcmd				" display incomplete commands
filetype plugin indent on		" load file type plugins + indentation
set autoread " Set to auto read when a file is changed from the outside
set history=700 " Sets how many lines of history VIM has to remember
set wildmenu " command completion
set ruler " show current position
set relativenumber
set hid " hide buffer when abandoned
set lazyredraw " more performance for macros
set viminfo^=% " Remember info about open buffers on close
set laststatus=2 " Always display the statusline in all windows
set scrolloff=7

" undo
set undofile
set undodir=~/.vim/undo
set nobackup
set noswapfile

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" disable bells
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Whitespace
set nowrap				" don't wrap lines
set tabstop=2 shiftwidth=2		" a tab is two spaces
set softtabstop=2
set expandtab				" use spaces, not tabs
set backspace=indent,eol,start		" backspace through everything in insert mode
set whichwrap+=<,>,h,l

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" paste mode toggle (needed when using autoindent/smartindent)
map <F10> :set paste<CR>
map <F11> :set nopaste<CR>
imap <F10> <C-O>:set paste<CR>
imap <F11> <nop>
set pastetoggle=<F11>

" Searching
set hlsearch				" highlight matches
set incsearch				" incremental searching
set ignorecase				" searches are case insensitive
set smartcase				" ... unless they contain at least one capital letter
set magic " for regular expressions
nnoremap / /\
vnoremap / /\v

" show matched brackets for 200ms
set showmatch 
set mat=2

" colors & theme
colorscheme mustang
let g:airline_powerline_fonts=1
" Favorite Color Scheme
if has("gui_running")
  " Remove Toolbar
  set guioptions-=T
  " Remove Menu
  set guioptions-=m
  " Don't show scroll bars in the GUI
  set guioptions-=L
  set guioptions-=r
  "Terminus is AWESOME
  "set guifont=Terminus\ 9
  set guifont=Inconsolata-dz\ for\ Powerline:h10
else
  set t_Co=256
  let g:rehash256 = 1
endif
colorscheme mustang
highlight ColorColumn guibg=DimGray

"" macrotime ------------------------------------------------------------------
"
" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
  set wildignore+=.git\*,.hg\*,.svn\*
endif

" Return to last edit position when opening files
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \ exe "normal! g`\"" |
     \ endif

" Remap the tab key to do autocompletion or indentation depending on the
" context (from http://www.vim.org/tips/tip.php?tip_id=102)
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=In

"" let the mappings begin! -----------------------------------------------------

" setting leader to , for faster shortcuts 
let mapleader = ","
let g:mapleader = ","

" fast edit of vimrc
nmap <silent> <leader>v :e $MYVIMRC<cr>

" fast esc
imap jj <esc>

" Unite mappings
call unite#custom_source('file_rec', 'matchers', ['matcher_fuzzy'])

nnoremap <leader>t :Unite -start-insert -no-split -buffer-name=files file_rec<cr>
nnoremap <leader>f :Unite -start-insert -no-split -buffer-name=files file_rec/async<cr>
nnoremap <leader>r :Unite -start-insert -no-split -buffer-name=mru file_mru<cr>
nnoremap <leader>o :Unite -start-insert -no-split -buffer-name=outline outline<cr>
nnoremap <leader>y :Unite -no-split -buffer-name=yank    history/yank<cr>
nnoremap <leader>e :Unite -no-split -buffer-name=buffer  buffer<cr>

" Custom mappings for the unite buffer
autocmd FileType unite call s:unite_settings()
  function! s:unite_settings()
    " Play nice with supertab
    let b:SuperTabDisabled=1
    " Enable navigation with control-j and control-k in insert mode
    imap <buffer> <C-j>   <Plug>(unite_select_next_line)
    imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
  endfunction


" Fast saving
nmap <leader>w :w!<cr>

" :W sudo saves the file (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" disable highlights on <leader> space
map <silent> <leader><space> :noh<cr>

" Close the current buffer
map <leader>bd :bdelete<cr>

" Remap VIM 0 to first non-blank character
map 0 ^

