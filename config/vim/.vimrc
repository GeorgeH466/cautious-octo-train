" ════════════════════════════════════════════════════════════════════════
"  CYBERDECK // .vimrc — hacker-themed, dependency-free (works on stock vim)
" ════════════════════════════════════════════════════════════════════════
set nocompatible
filetype plugin indent on
syntax on

" ── Appearance ──────────────────────────────────────────────────────────
set termguicolors
set background=dark
" Built-in fallback palette tuned to the Ghost theme (no plugin needed)
highlight Normal       guifg=#e6ffff guibg=#0a0a0a ctermfg=195 ctermbg=232
highlight Comment      guifg=#3d7a78 gui=italic ctermfg=66
highlight Constant     guifg=#ffb000 ctermfg=214
highlight String       guifg=#00ff41 ctermfg=46
highlight Identifier   guifg=#7dfff8 ctermfg=123
highlight Statement    guifg=#00fff5 gui=bold ctermfg=51
highlight PreProc      guifg=#ff5ce1 ctermfg=207
highlight Type         guifg=#00b8ff ctermfg=39
highlight Special      guifg=#ffd166 ctermfg=221
highlight Error        guifg=#ffffff guibg=#ff0040 ctermfg=15 ctermbg=197
highlight Todo         guifg=#0a0a0a guibg=#ffb000 gui=bold ctermfg=232 ctermbg=214
highlight LineNr       guifg=#1f3a3a ctermfg=238
highlight CursorLineNr guifg=#00fff5 gui=bold ctermfg=51
highlight CursorLine   guibg=#10161a ctermbg=234
highlight StatusLine   guifg=#0a0a0a guibg=#00fff5 gui=bold ctermfg=232 ctermbg=51
highlight StatusLineNC guifg=#5a7a78 guibg=#10161a ctermfg=66 ctermbg=234
highlight Pmenu        guifg=#e6ffff guibg=#10161a ctermfg=195 ctermbg=234
highlight PmenuSel     guifg=#0a0a0a guibg=#00fff5 ctermfg=232 ctermbg=51
highlight Visual       guibg=#0f3a3a ctermbg=237
highlight Search       guifg=#0a0a0a guibg=#ffb000 ctermfg=232 ctermbg=214
highlight VertSplit    guifg=#1a2a2a guibg=#0a0a0a ctermfg=237 ctermbg=232
highlight MatchParen   guifg=#00fff5 guibg=#1a2a2a gui=bold ctermfg=51 ctermbg=237
try | colorscheme evening | catch | endtry

set number relativenumber cursorline signcolumn=yes
set list listchars=tab:▸\ ,trail:·,extends:›,precedes:‹,nbsp:␣
set fillchars=vert:│,fold:─,eob:\
set laststatus=2 showcmd ruler noshowmode
set statusline=%#StatusLine#\ ◢\ %F%m%r%h%w\ │\ %{&fileencoding}\ │\ %y\ │\ %l:%c\ %p%%\

" ── Behaviour ───────────────────────────────────────────────────────────
set encoding=utf-8 fileformats=unix,dos,mac
set hidden autoread confirm mouse=a clipboard=unnamedplus
set backspace=indent,eol,start whichwrap+=<,>,h,l
set scrolloff=8 sidescrolloff=8 splitbelow splitright
set timeoutlen=400 updatetime=300
set undofile undodir=~/.vim/undo backupcopy=yes
set noswapfile nobackup nowritebackup
call mkdir(expand('~/.vim/undo'), 'p')

" ── Indentation / search ────────────────────────────────────────────────
set expandtab tabstop=4 shiftwidth=4 softtabstop=4 smartindent autoindent
set ignorecase smartcase incsearch hlsearch gdefault
set wildmenu wildmode=longest:full,full wildignore=*.o,*.pyc,__pycache__,.git
set completeopt=menuone,noselect
set foldmethod=indent foldlevelstart=99

" ── Leader = Space ──────────────────────────────────────────────────────
let mapleader=" "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap <leader>/ :nohlsearch<CR>
nnoremap <leader>n :set relativenumber!<CR>
nnoremap <leader>e :Explore<CR>
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>t :terminal<CR>
nnoremap <leader>b :ls<CR>:buffer<Space>
nnoremap <leader>d :bd<CR>
nnoremap <leader>p :set paste!<CR>
vnoremap <leader>y "+y
nnoremap <leader>p "+p
" tmux-style pane movement
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
vnoremap < <gv
vnoremap > >gv
" Keep cursor centred on search jumps
nnoremap n nzzzv
nnoremap N Nzzzv
" Sudo-write typo saver
command! W execute 'w !sudo tee % > /dev/null' | edit!

" ── Language touches ────────────────────────────────────────────────────
augroup CyberdeckFiletypes
  autocmd!
  autocmd FileType python setlocal tabstop=4 shiftwidth=4
  autocmd FileType sh,bash,zsh setlocal tabstop=2 shiftwidth=2
  autocmd FileType json,yaml,html,css,javascript setlocal tabstop=2 shiftwidth=2
  autocmd FileType make setlocal noexpandtab
  autocmd FileType markdown setlocal wrap linebreak spell spelllang=en_gb
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  autocmd BufWritePre * %s/\s\+$//e
augroup END
" Checker helpers for deck work
command! ShellCheck !shellcheck %
command! PyCheck !python3 -m py_compile % && echo OK
command! JsonFmt %!python3 -m json.tool
