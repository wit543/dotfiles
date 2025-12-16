" ============================================================================
"                         VIM CONFIGURATION
"                    github.com/wit543/dotfiles
" ============================================================================
" Cross-platform Vim/Neovim configuration
" Plugin Manager: vim-plug (auto-installs on first run)
" ============================================================================

set nocompatible

" ============================================================================
" VIM-PLUG AUTO-INSTALL
" ============================================================================
" NOTE: Automatically installs vim-plug if not present

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ============================================================================
" PLUGINS
" ============================================================================
" NOTE: Run :PlugInstall to install, :PlugUpdate to update

call plug#begin('~/.vim/plugged')

" --------------------------
" Navigation & Motion
" --------------------------
Plug 'supasorn/vim-easymotion'          " Quick cursor movement
Plug 'haya14busa/incsearch.vim'         " Improved incremental search
Plug 'dahu/vim-fanfingtastic'           " Extended f/t motions
Plug 'wellle/targets.vim'               " Additional text objects

" --------------------------
" Editing
" --------------------------
Plug 'scrooloose/nerdcommenter'         " Easy commenting (<leader>c)
Plug 'tpope/vim-surround'               " Surround text objects
Plug 'tpope/vim-repeat'                 " Repeat plugin commands with .
Plug 'PeterRincker/vim-argumentative'   " Argument text objects
Plug 'godlygeek/tabular'                " Text alignment

" --------------------------
" File Navigation
" --------------------------
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'                 " FZF integration
Plug 'jremmen/vim-ripgrep'              " Ripgrep integration
Plug 'pbogut/fzf-mru.vim'               " Most recently used files
Plug 'vim-scripts/FuzzyFinder'          " Fuzzy file finder
Plug 'vim-scripts/mru.vim'              " MRU file list
Plug 'scrooloose/nerdtree'              " File tree sidebar

" --------------------------
" Utilities
" --------------------------
Plug 'xolox/vim-session'                " Session management
Plug 'xolox/vim-misc'                   " Required by vim-session
Plug 'vim-scripts/a.vim'                " Switch header/source (.h/.c)
Plug 'mbbill/undotree'                  " Visual undo history
Plug 'Shougo/neocomplcache'             " Auto-completion
Plug 'wesQ3/vim-windowswap'             " Swap windows easily
Plug 'skywind3000/asyncrun.vim'         " Async shell commands
Plug 'drmingdrmer/vim-toggle-quickfix'  " Toggle quickfix window
Plug 'vim-scripts/L9'                   " Required by FuzzyFinder

" --------------------------
" Git Integration
" --------------------------
Plug 'tpope/vim-fugitive'               " Git commands
Plug 'tpope/vim-dispatch'               " Async builds
Plug 'radenling/vim-dispatch-neovim'    " Neovim dispatch support
Plug 'airblade/vim-gitgutter'           " Git diff in gutter

" --------------------------
" Appearance
" --------------------------
Plug 'bling/vim-airline'                " Status line
Plug 'vim-airline/vim-airline-themes'   " Airline themes
Plug 'morhetz/gruvbox'                  " Gruvbox colorscheme
Plug 'arcticicestudio/nord-vim'         " Nord colorscheme
Plug 'junegunn/seoul256.vim'            " Seoul256 colorscheme
Plug 'freeo/vim-kalisi'                 " Kalisi colorscheme
Plug 'xolox/vim-colorscheme-switcher'   " Easy colorscheme switching

" --------------------------
" Tags & Ctags
" --------------------------
if executable('ctags')
  Plug 'majutsushi/tagbar'              " Tag sidebar
  if v:version >= 800
    Plug 'ludovicchabant/vim-gutentags' " Auto tag generation
  endif
endif

" --------------------------
" Bookmarks
" --------------------------
Plug 'kshenoy/vim-signature'            " Show marks in gutter
Plug 'AndrewRadev/simple_bookmarks.vim' " Simple bookmarks

" --------------------------
" Syntax & Languages
" --------------------------
Plug 'sheerun/vim-polyglot'             " Language pack
Plug 'othree/html5.vim'                 " HTML5 syntax

" --------------------------
" LaTeX
" --------------------------
Plug 'lervag/vimtex'                    " LaTeX support
Plug 'sirver/ultisnips'                 " Snippets engine

" --------------------------
" Tmux
" --------------------------
Plug 'vim-utils/vim-husk'               " Tmux yank support

call plug#end()

" ============================================================================
" APPEARANCE
" ============================================================================

set background=dark
colorscheme gruvbox

set t_Co=256                            " 256 colors
set number                              " Line numbers
set laststatus=2                        " Always show status line
set display=lastline                    " Show partial lines

" Disable visual bell
autocmd GUIEnter * set visualbell t_vb=

" ============================================================================
" GENERAL SETTINGS
" ============================================================================

set encoding=utf-8
set mouse=a                             " Enable mouse
set noswapfile                          " No swap files
set noeb                                " No error bells
set autoread                            " Auto-reload changed files

" ============================================================================
" INDENTATION
" ============================================================================

set smartindent
set autoindent
set cindent
set smarttab
set tabstop=2
set shiftwidth=2
set expandtab                           " Spaces instead of tabs

" ============================================================================
" SEARCH
" ============================================================================

set ignorecase                          " Case insensitive search
set smartcase                           " Unless uppercase is used
set gdefault                            " Global replace by default
set incsearch                           " Incremental search

" ============================================================================
" COMPLETION
" ============================================================================

set wildmenu                            " Command-line completion
set wildmode=list:longest,full
set completeopt-=preview                " No preview window

" ============================================================================
" FOLDING
" ============================================================================

set foldmethod=indent
set scrolloff=3                         " Lines above/below cursor

" Open all folds on file open
augroup OpenAllFoldsOnFileOpen
    autocmd!
    autocmd BufRead * normal zR
augroup END

" ============================================================================
" GUI SETTINGS
" ============================================================================

set go-=m                               " No menu bar
set go-=r                               " No right scrollbar
set go-=L                               " No left scrollbar

" Font configuration (OS-specific)
let os = substitute(system('uname'), "\n", "", "")
if os == "Linux"
  set guifont=Droid\ Sans\ Mono\ for\ Powerline\ 11
else
  set guifont=DejaVu_Sans_Mono_for_Powerline:h12
endif

" ============================================================================
" PLUGIN CONFIGURATION
" ============================================================================

" --------------------------
" Airline
" --------------------------
if !empty(glob('~/.vim/plugged/vim-airline'))
  let g:airline_powerline_fonts = 1
  let g:airline_theme = "bubblegum"
  let g:airline_section_z = airline#section#create_right(['%l'])
  let g:airline_section_warning = airline#section#create_right(['%c'])
endif

" --------------------------
" NeoComplCache
" --------------------------
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_max_list = 15
let g:neocomplcache_enable_fuzzy_completion = 1
let g:neocomplcache_fuzzy_completion_start_length = 2

" --------------------------
" EasyMotion
" --------------------------
let g:EasyMotion_leader_key = '<leader>'

" --------------------------
" Session
" --------------------------
let g:session_autoload = 'no'
let g:session_autosave = 'yes'

" --------------------------
" GitGutter
" --------------------------
let g:gitgutter_enabled = 0             " Disabled by default

" --------------------------
" Colorscheme Switcher
" --------------------------
let g:colorscheme_switcher_define_mappings = 0
let g:colorscheme_switcher_exclude_builtins = 1

" --------------------------
" FuzzyFinder
" --------------------------
let g:fuf_fuzzyRefining = 0
let g:fuf_maxMenuWidth = 150
let g:fuf_patternSeparator = ' '
let g:fuf_file_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp|\.class$'
let g:fuf_keyOpenVsplit = '<C-v>'

" --------------------------
" AsyncRun
" --------------------------
let g:asyncrun_open = 8
let g:asyncrun_bell = 1

" --------------------------
" Vimtex
" --------------------------
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_quickfix_mode = 0
set conceallevel=1
let g:tex_conceal = 'abdmg'

" --------------------------
" UltiSnips
" --------------------------
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" --------------------------
" Ctags
" --------------------------
let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'

" --------------------------
" Netrw
" --------------------------
let g:netrw_silent = 1
let g:fugitive_force_bang_command = 1

" ============================================================================
" KEY MAPPINGS
" ============================================================================

" --------------------------
" Save
" --------------------------
nmap <c-s> :w<CR>
imap <c-s> <Esc>:w<CR>a

" --------------------------
" Navigation
" --------------------------
nnoremap j gj                           " Move by visual line
nnoremap k gk
noremap Y y$                            " Y yanks to end of line
vnoremap y y`>                          " Keep cursor after yank

" --------------------------
" Search
" --------------------------
map / <Plug>(incsearch-forward)
map <s-r> :History:<CR>                 " Command history

" --------------------------
" Completion
" --------------------------
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <expr><C-h> neocomplcache#undo_completion()
inoremap <expr><C-k> neocomplcache#close_popup()

" --------------------------
" Clipboard
" --------------------------
map "k "+                               " System clipboard
map "m "*                               " Mouse clipboard

" --------------------------
" File Navigation
" --------------------------
nmap <F2> :FufFileWithCurrentBufferDir<CR>
imap <F2> <esc>:FufFileWithCurrentBufferDir<CR>
nmap <s-F2> :FufRenewCache<CR>
nmap <F3> :FufBuffer<CR>
imap <F3> <esc>:FufBuffer<CR>
nmap <F4> :FZFMru --no-sort<CR>
nmap <F5> :e %<CR>
imap <F5> <esc>:e %<CR>

" --------------------------
" Quickfix
" --------------------------
nnoremap \[ :cp<Cr>
nnoremap \] :cn<Cr>
nmap <F10> <Plug>window:quickfix:toggle

" --------------------------
" NERDTree
" --------------------------
noremap <C-n> :NERDTreeToggle<CR>
map <leader>r :NERDTreeFind<cr>

" --------------------------
" Commenting
" --------------------------
map <c-c> <plug>NERDCommenterToggle<c-m>

" --------------------------
" EasyMotion
" --------------------------
nmap <SPACE> <leader>s
vmap <SPACE> <leader>s
map <c-j> <leader>j
vmap <c-j> <leader>j
map <c-k> <leader>k
vmap <c-k> <leader>k
nmap \p :call EasyMotion#SelectLinesPaste()<CR>

" --------------------------
" Ripgrep
" --------------------------
nnoremap gr :Rg --max-depth=1 '\b<cword>\b' %:p:h/<CR>
nnoremap <c-f> <esc>:cd %:p:h<CR>:Rg --max-depth=1
command! -nargs=1 Gr call GrepCurrentDirectory(<f-args>)

" --------------------------
" Make
" --------------------------
nnoremap \m :w<CR>:execute "cd %:p:h \| try \| cd bin \| catch \| try \| cd ../bin \| catch \| endtry \| endtry"<CR>:make %:t:r<CR>

" --------------------------
" Tags
" --------------------------
nmap <F8> :TagbarToggle<CR>

" --------------------------
" Colorscheme
" --------------------------
nmap <F9> :NextColorScheme<CR>
nmap <s-F9> :PrevColorScheme<CR>

" --------------------------
" Git
" --------------------------
nnoremap <silent> <leader>gg :GitGutterToggle<CR>
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gc :Gcommit -m "auto commit"<CR>
nnoremap <silent> <leader>gp :Git push<CR>

" --------------------------
" Tabularize
" --------------------------
nmap <Leader>a= :Tabularize /=<CR>
vmap <Leader>a= :Tabularize /=<CR>

" --------------------------
" Visual Mode
" --------------------------
vnoremap < <gv                          " Stay in visual mode
vnoremap > >gv

" --------------------------
" Header/Source Toggle
" --------------------------
map <c-h> <esc>:A<CR>

" --------------------------
" Misc
" --------------------------
nnoremap =<SPACE> i <ESC>la <ESC>h      " Add spaces around cursor
noremap -= =a}``                        " Format block
map [[ ?{<CR>w99[{
map ]] j0[[%/{<CR>

" ============================================================================
" COMMANDS
" ============================================================================

command! OS OpenSession
command! SS SaveSession
command! RE RestartVim
command! W w

" ============================================================================
" AUTOCOMMANDS
" ============================================================================

" --------------------------
" Filetypes
" --------------------------
filetype plugin on

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete | set ts=2 | set sw=2
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

autocmd BufNewFile,BufReadPost *.ejs set filetype=html
autocmd BufNewFile,BufRead *.cuh set filetype=cpp
autocmd BufNewFile,BufRead *.as setf actionscript

" Auto-open quickfix window
autocmd QuickFixCmdPost [^l]* nested botright cwindow 8
autocmd QuickFixCmdPost l* nested lwindow

" Remember cursor position
autocmd BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Auto-update tags
autocmd BufWritePost *.cpp,*.h,*.c,*.cc call UpdateTags()

" Quickfix status line
augroup QuickfixStatus
    au! BufWinEnter quickfix setlocal
        \ statusline=%t\ [%{g:asyncrun_status}]\ %{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
augroup END

" ============================================================================
" HIGHLIGHT
" ============================================================================

hi MatchParen guibg=NONE gui=underline

" ============================================================================
" EXTERNAL FUNCTIONS
" ============================================================================
" NOTE: Load custom functions from ~/.vimrc.functions if exists

if filereadable(expand("~/.vimrc.functions"))
  source ~/.vimrc.functions
endif

" ============================================================================
" END OF VIMRC
" ============================================================================
