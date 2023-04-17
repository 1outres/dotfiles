" dein.vim ======================================
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'


let $CACHE = expand('~/.cache')
if !isdirectory($CACHE)
  call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
  let s:dein_dir = fnamemodify('dein.vim', ':p')
  if !isdirectory(s:dein_dir)
    let s:dein_dir = $CACHE .. '/dein/repos/github.com/Shougo/dein.vim'
    if !isdirectory(s:dein_dir)
      execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    endif
  endif
  execute 'set runtimepath^=' .. substitute(
        \ fnamemodify(s:dein_dir, ':p') , '[/\\]$', '', '')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " プラグインリスト(toml)
  let g:rc_dir    = expand('$HOME/.vim')
  if !isdirectory(g:rc_dir)
    call mkdir(g:rc_dir, 'p')
  endif
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " tomlのロード
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable
if dein#check_install()
  call dein#install()
endif

let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif

" ===============================================

set number            " 画面左端に行番号を表示
set signcolumn=yes    " 画面左端にサイン列を常に表示
set laststatus=2      " 画面最下部に常にステータスラインを表示
set cmdheight=2       " 画面最下部(ステータス行より下)のメッセージ表示欄を2行にする
set showtabline=2     " タブ毎に常にタブラインを表示

set virtualedit=block " 矩形選択時に仮想編集を有効化
set wildmenu          " コマンドラインでTAB補完時に候補メニューを表示
set wildignorecase    " コマンドラインでTAB補完時に大文字・小文字を区別しない

set tabstop=2         " タブを2文字分にする
set expandtab         " タブの代わりに半角スペースを使用
set shiftwidth=2      " インデントを半角スペース2文字にする
set smartindent       " 新しい行追加時に自動でインデントを追加

set hlsearch          " 文字列検索のハイライト
set ignorecase        " 文字列検索で大文字・小文字を区別しない
set smartcase         " 文字列検索で大文字を含んでいたらignorecaseを上書きし、大文字・小文字を区別する
set incsearch         " インクリメンタルサーチ

set noswapfile        " スワップファイル(.swp)を生成しない
set nobackup          " バックアップファイル(~)を生成しない
set noundofile        " undoファイル(.un~)を生成しない
set encoding=utf-8    " Vim内部で使われる文字エンコーディングにutf-8にする

set mouse-=a           " マウス操作を無効にする

let mapleader = "\<Space>" " スペースをリーダーキーにする


" keymap ======================================


" 文字列検索のハイライトオフ
nmap <silent> <Esc><Esc> :<C-u>nohlsearch<CR><Esc>

" Open fern
nnoremap <C-n> :Fern . -reveal=%<CR>

" fzf
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>g :GFiles<CR>
nnoremap <silent> <leader>G :GFiles?<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>r :Rg<CR>

nnoremap <Leader>w ^
nnoremap <Leader>s $

" plugins ======================================

" vimdoc-ja - helpの日本語化
set helplang=ja,en

" vim-airline - powerlien status
let g:airline_section_z = ''

" dracula - theme
colorscheme dracula
let g:airline_theme='dracula'

" fern - filer
let g:fern#default_hidden=1
let g:fern#renderer = 'nerdfont'
let g:fern#renderer#nerdfont#indent_markers = 1

" vim-gitgutter - shwo git status by line num
set updatetime=100

let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'

" lexima
" to be able to override keymaps of lexima
let g:lexima_no_default_rules = 1
let g:lexima_map_escape = ""
call lexima#set_default_rules()

" auto-save
let g:auto_save = 1

" coc.nvim
" エンターで確定
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<C-r>=lexima#expand('<LT>CR>', 'i')\<CR><C-r>=coc#on_enter()\<CR>"
" Escで閉じる
inoremap <silent><expr> <buffer> <nowait> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<C-r>=lexima#insmode#escape()\<Cr>\<Esc>"

" functions ======================================

" カーソルの位置を記憶
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END
