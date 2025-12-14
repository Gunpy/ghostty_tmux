# Ghostty + tmux setup (macOS)

[English](#english-version) | [Русская версия](#русская-версия)

---

## English version

<details open>
<summary><strong>English</strong></summary>

# Ghostty + tmux setup (macOS)

This setup is intended for developers who want to use:

- **Ghostty** as the main development terminal;
- **tmux** to manage sessions, windows, and panes;
- while keeping the default macOS Terminal unchanged (no automatic tmux startup there).

## Stack and behavior

- When **Ghostty** starts an interactive `zsh` session, `tmux` (session `main`) is started automatically.
- In **macOS Terminal.app**, `tmux` is not started automatically — you get a normal `zsh` shell.
- Configuration files live in the repository under `config/` and are copied into `$HOME`.

---

## 1. Requirements

- macOS  
- [Homebrew](https://brew.sh/) (for installing tmux)  
- [Ghostty](https://ghostty.org/) installed in `/Applications/Ghostty.app`  
- Optional: `JetBrainsMono Nerd Font` (or any other monospaced font you prefer)

---

## 2. Repository config structure

```text
config/
  ghostty/
    config
  tmux/
    tmux.conf
  zsh/
    tmux-ghostty.zsh
README.md

```

### 2.1 Purpose of each file

-   `config/ghostty/config` - Ghostty configuration.
    
-   `config/tmux/tmux.conf` - main tmux configuration.
    
-   `config/zsh/tmux-ghostty.zsh` - snippet that enables tmux only in Ghostty.
    

----------

## 3. Install tmux via Homebrew

```bash
brew install tmux
tmux -V

```

----------

## 4. tmux configuration

### 4.1. Main tmux config

Repository file: `config/tmux/tmux.conf`

```tmux
unbind-key -a -T root

# Pane borders
set -g pane-border-lines "double"

# Window/pane numbering starts from 1
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Vi-style mode keys (copy-mode, etc.)
setw -g mode-keys vi

# Enable mouse support
set -g mouse on

# No ESC delay
set -s escape-time 0

# Scrollback history
set -g history-limit 2000

# Reload config: Alt(Option)+r
bind -n M-r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

# Session/window tree: Alt(Option)+s
bind -n M-s choose-tree -s

# Fast window switch: Alt(Option)+1..9
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

# Pane navigation: Alt(Option)+Arrow keys
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# Pane resizing: Alt(Option)+Shift+Arrow keys
bind -n M-S-Left  resize-pane -L 5
bind -n M-S-Right resize-pane -R 5
bind -n M-S-Up    resize-pane -U 3
bind -n M-S-Down  resize-pane -D 3

# Splits
bind -n M-h split-window -v   # Alt(Option)+h - horizontal split (top/bottom)
bind -n M-v split-window -h   # Alt(Option)+v - vertical split (left/right)

# Windows
bind -n M-Enter new-window    # Alt(Option)+Enter - new window
bind -n M-c kill-pane         # Alt(Option)+c - close current pane
bind -n M-q kill-window       # Alt(Option)+q - close current window
bind -n M-d detach            # Alt(Option)+d - detach from session
bind -n M-Q confirm-before -p "Kill entire session? (y/n)" kill-session

# Copy-mode (vi)
bind -T copy-mode-vi v send -X begin-selection
# macOS: copy to system clipboard
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"

# Search
bind -n M-/ copy-mode \; command-prompt -p "(search down)" "send -X search-forward '%%%'"
bind -n M-? copy-mode \; command-prompt -p "(search up)"   "send -X search-backward '%%%'"

# tmux plugins (via TPM)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'egel/tmux-gruvbox'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Auto save/restore sessions
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# TPM loader
run '~/.config/tmux/plugins/tpm/tpm'

```

Copy config to your system:

```bash
mkdir -p ~/.config/tmux
cp config/tmux/tmux.conf ~/.config/tmux/tmux.conf

```

### 4.2. `.tmux.conf` in the home directory

Create `~/.tmux.conf` that simply sources the main config:

```bash
cat > ~/.tmux.conf << 'EOF'
source-file ~/.config/tmux/tmux.conf
EOF

```

### 4.3. Install TPM and plugins

Install TPM:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

```

Then:

```bash
tmux

```

Inside tmux:

-   Press `Ctrl+b`, then `Shift+I` (capital `I`) to install plugins.
    

----------

## 5. Ghostty configuration

Repository file: `config/ghostty/config`

```text
# fonts
font-family = "JetBrainsMono Nerd Font"
font-size = 13

# cursor motion
cursor-style = block
cursor-style-blink = true

# hot-keys for Ghostty (on top of tmux)
keybind = cmd+shift+t=new_tab
keybind = cmd+alt+left=previous_tab
keybind = cmd+alt+right=next_tab

# macOS: Option = Alt (Meta) for tmux (M-…)
macos-option-as-alt = left

```

Copy config to your system:

```bash
mkdir -p ~/.config/ghostty
cp config/ghostty/config ~/.config/ghostty/config

```

Reload Ghostty config:

```bash
ghostty +reload-config

```

(or just restart Ghostty)

----------

## 6. Auto-start tmux only in Ghostty (zsh)

Repository file: `config/zsh/tmux-ghostty.zsh`

```sh
# tmux only in Ghostty
if [[ $- == *i* ]]; then
  # check that the terminal is Ghostty
  if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    if [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
      tmux attach -t main || tmux new -s main
    fi
  fi
fi

```

Include it in `~/.zshrc`:

```bash
echo 'source ~/path/to/repo/config/zsh/tmux-ghostty.zsh' >> ~/.zshrc
source ~/.zshrc

```

Where `~/path/to/repo` is the path to your cloned repository.

----------

## 7. Behavior after setup

-   Launching **Ghostty**:
    
    -   starts `zsh`;
        
    -   in an interactive shell, if the terminal is Ghostty and there is no active tmux session, it executes:
        
        ```bash
        tmux attach -t main || tmux new -s main
        
        ```
        
    -   as a result, you land directly inside the `main` tmux session.
        
-   Launching **Terminal.app**:
    
    -   the `TERM_PROGRAM` value differs from `ghostty`;
        
    -   the tmux auto-start block does not run;
        
    -   you get a regular `zsh` shell without tmux.
        

----------

## 8. Usage

Below is how to use the Ghostty + tmux setup in real development workflows.

### 8.1. tmux model: sessions, windows, panes

tmux operates with three main concepts:

-   **Session** - a logical work context (e.g., project, remote server).
    
-   **Window** - a “tab” within a session (usually representing a mode: code, server, logs, etc.).
    
-   **Pane** - a split region of a window (multiple terminals on one screen).
    

Ghostty sits above this and provides native macOS windows/tabs. The layout and workflow logic lives primarily inside tmux.

----------

### 8.2. Sessions

Session `main` is created/attached automatically when Ghostty starts.

Additional commands:

```bash
# create a new session
tmux new -s my-session

# list existing sessions
tmux ls

# attach to an existing session
tmux attach -t my-session
tmux attach -t main

# switch to another session (from inside tmux)
tmux switch-client -t my-session

```

Exiting tmux:

-   `Alt(Option)+d` - detach (session keeps running in the background, can be reattached).
    
-   `Alt(Option)+Q` - prompt to kill the entire session (`kill-session` with confirmation).
    

----------

### 8.3. Windows

Windows are convenient as logical tabs inside one project/session, for example:

-   window 1 - editor/code,
    
-   window 2 - backend/server,
    
-   window 3 - logs/monitoring.
    

Hotkeys:

-   **New window:** `Alt(Option)+Enter`
    
-   **Close current window:** `Alt(Option)+q`  
    (no extra confirmation from tmux, the window closes immediately)
    
-   **Switch between windows:**
    
    -   `Alt(Option)+1` … `Alt(Option)+9` - jump to window by number  
        (numbering starts from 1 and is renumbered automatically due to `set -g renumber-windows on`)
        
-   **Session/window tree:**
    
    -   `Alt(Option)+s` - open tree view (sessions/windows/panes); navigate with arrows, `Enter` to select.
        

----------

### 8.4. Panes

Panes are “splits” inside a single tmux window.

Create splits:

-   `Alt(Option)+h` - horizontal split (screen split into top/bottom).
    
-   `Alt(Option)+v` - vertical split (screen split into left/right).
    

Navigate between panes:

-   `Alt(Option)+Left` - focus pane to the left
    
-   `Alt(Option)+Right` - focus pane to the right
    
-   `Alt(Option)+Up` - focus pane above
    
-   `Alt(Option)+Down` - focus pane below
    

Resize panes:

-   `Alt(Option)+Shift+Left` - grow left pane (shrink right) by 5 columns
    
-   `Alt(Option)+Shift+Right` - grow right pane (shrink left) by 5 columns
    
-   `Alt(Option)+Shift+Up` - grow upper pane (shrink lower) by 3 rows
    
-   `Alt(Option)+Shift+Down` - grow lower pane (shrink upper) by 3 rows
    

Close current pane:

-   `Alt(Option)+c` - close the current pane (`kill-pane`)
    

----------

### 8.5. Copying and clipboard integration (macOS)

tmux supports copy-mode; with `mode-keys vi` it behaves like vi.

Enter copy-mode with search:

```bash
Alt(Option)+/   # copy-mode + search forward
Alt(Option)+?   # copy-mode + search backward

```

Or simply press `Alt(Option)+/` and then navigate manually.

In `copy-mode-vi`:

-   `v` - start selection
    
-   arrows or `h/j/k/l` - move cursor and selection
    
-   `y` - copy selection and exit copy-mode
    

Because we configured:

```tmux
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"

```

the selection is sent directly to the macOS system clipboard via `pbcopy`, so you can paste into any app with `Cmd+V`.

----------

### 8.6. Searching through history

From within tmux at any time:

-   `Alt(Option)+/` - enter copy-mode and prompt for forward search.
    
-   `Alt(Option)+?` - same, but search backward.
    

Then:

-   type the search string,
    
-   use `n` / `N` in vi-style copy-mode to jump to next/previous match.
    

----------

### 8.7. Reloading tmux configuration

After editing `~/.config/tmux/tmux.conf`, you do not need to restart the tmux session.

Hotkey:

-   `Alt(Option)+r` - runs:
    

```tmux
source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

```

tmux will apply the new configuration on the fly.

----------

### 8.8. Example workflow

1.  Open Ghostty - it automatically attaches/creates the `main` session.
    
2.  In window 1:
    
    ```text
    Alt(Option)+v  # vertical split: editor on the left, shell on the right
    Alt(Option)+Down / Alt(Option)+Up / Alt(Option)+Left / Alt(Option)+Right
    # move between panes
    
    ```
    
3.  `Alt(Option)+Enter` - create window 2:  
    run backend server, watcher, tests, etc.
    
4.  `Alt(Option)+3` - jump to window 3:  
    view logs, `tail` files, monitoring tools.
    
5.  When you need to temporarily leave tmux but keep everything running:  
    `Alt(Option)+d` - detach; all processes and layout continue to run in the background.
    
6.  Later, reattach to the same layout:
    
    ```bash
    tmux attach -t main
    
    ```
    

Ghostty remains the visual shell (macOS windows/tabs). All layout, session, window, and pane logic is implemented via tmux.

</details>

---

## Русская версия

<details>
<summary><strong>Русский</strong></summary>

Связка предназначена для разработчиков, которые хотят использовать:

- **Ghostty** как основной dev-терминал;
- **tmux** для управления сессиями, окнами и панелями;
- при этом оставить системный macOS Terminal без изменений (без автоматического запуска tmux).

## Стек и поведение

- При запуске **Ghostty** внутри интерактивной `zsh`-сессии автоматически стартует `tmux` (сессия `main`).
- В **macOS Terminal.app** `tmux` не запускается автоматически, работает обычный `zsh`.
- Конфигурации лежат в репозитории в папке `config/` и копируются в `$HOME`.

---

## 1. Требования

- macOS
- [Homebrew](https://brew.sh/) (для установки tmux)
- [Ghostty](https://ghostty.org/) установлен в `/Applications/Ghostty.app`
- Опционально: шрифт `JetBrainsMono Nerd Font` (или любой другой моноширинный шрифт по вкусу)

---

## 2. Структура конфигов в репозитории

```text
config/
  ghostty/
    config
  tmux/
    tmux.conf
  zsh/
    tmux-ghostty.zsh
README.md
```

### 2.1 Назначение:

- config/ghostty/config - конфигурация Ghostty.
- config/tmux/tmux.conf - основной конфиг tmux.
- config/zsh/tmux-ghostty.zsh - сниппет для включения tmux только в Ghostty.

## 3. Установить tmux через Homebrew:

```code
brew install tmux
tmux -V
```


## 4. Настройка tmux
### 4.1. Основной конфиг tmux

Файл из репозитория: config/tmux/tmux.conf
```text
unbind-key -a -T root

# Граница панелей
set -g pane-border-lines "double"

# Нумерация окон/панелей с 1
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Vi-режим для копирования и навигации
setw -g mode-keys vi

# Мышь включена
set -g mouse on

# Без задержки escape
set -s escape-time 0

# История
set -g history-limit 2000

# Перезагрузка конфига: Alt(Option)+r
bind -n M-r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

# Дерево сессий/окон: Alt(Option)+s
bind -n M-s choose-tree -s

# Быстрый переход по окнам: Alt(Option)+1..9
bind -n M-1 select-window -t 1
bind -n M-2 select-window -t 2
bind -n M-3 select-window -t 3
bind -n M-4 select-window -t 4
bind -n M-5 select-window -t 5
bind -n M-6 select-window -t 6
bind -n M-7 select-window -t 7
bind -n M-8 select-window -t 8
bind -n M-9 select-window -t 9

# Навигация по панелям: Alt(Option)+стрелки
bind -n M-Left  select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up    select-pane -U
bind -n M-Down  select-pane -D

# Ресайз панелей: Alt(Option)+Shift+стрелки
bind -n M-S-Left  resize-pane -L 5
bind -n M-S-Right resize-pane -R 5
bind -n M-S-Up    resize-pane -U 3
bind -n M-S-Down  resize-pane -D 3

# Сплиты
bind -n M-h split-window -v   # Alt(Option)+h - горизонтальный сплит (верх/низ)
bind -n M-v split-window -h   # Alt(Option)+v - вертикальный сплит (лево/право)

# Окна
bind -n M-Enter new-window    # Alt(Option)+Enter - новое окно
bind -n M-c kill-pane         # Alt(Option)+c - закрыть панель
bind -n M-q kill-window       # Alt(Option)+q - закрыть окно
bind -n M-d detach            # Alt(Option)+d - detach
bind -n M-Q confirm-before -p "Kill entire session? (y/n)" kill-session

# Копирование в vi-режиме
bind -T copy-mode-vi v send -X begin-selection
# macOS: копируем в системный буфер обмена
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"

# Поиск
bind -n M-/ copy-mode \; command-prompt -p "(search down)" "send -X search-forward '%%%'"
bind -n M-? copy-mode \; command-prompt -p "(search up)"   "send -X search-backward '%%%'"

# Плагины tmux (TPM)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'egel/tmux-gruvbox'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Авто-сохранение/восстановление сессий
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'

# Загрузчик TPM
run '~/.config/tmux/plugins/tpm/tpm'
```

Копирование конфига в систему:
```text
mkdir -p ~/.config/tmux
cp config/tmux/tmux.conf ~/.config/tmux/tmux.conf
```

### 4.2. .tmux.conf в домашней директории

Создать файл ~/.tmux.conf, который подключает основной конфиг:
```text
cat > ~/.tmux.conf << 'EOF'
source-file ~/.config/tmux/tmux.conf
EOF
```

### 4.3. Установка TPM и плагинов

- Установка TPM:
```text
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```
- Запустить tmux:
```text
tmux
```
- Нажать Ctrl+b, затем Shift+I (большая i), чтобы установить плагины.

### 5. Конфигурация Ghostty

Файл из репозитория: config/ghostty/config
```text
# fonts
font-family = "JetBrainsMono Nerd Font"
font-size = 13

# cursor motion
cursor-style = block
cursor-style-blink = true

# hot-keys for Ghostty (поверх tmux)
keybind = cmd+shift+t=new_tab
keybind = cmd+alt+left=previous_tab
keybind = cmd+alt+right=next_tab

# macOS: Option = Alt (Meta) для tmux (M-…)
macos-option-as-alt = left
```
Копирование конфига в систему:
```text
mkdir -p ~/.config/ghostty
cp config/ghostty/config ~/.config/ghostty/config
```
```text
ghostty +reload-config
```

### 6. Автозапуск tmux только в Ghostty (zsh)

Файл из репозитория: config/zsh/tmux-ghostty.zsh
```text
# tmux only in Ghostty
if [[ $- == *i* ]]; then
  # проверяем, что терминал - Ghostty
  if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    if [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
      tmux attach -t main || tmux new -s main
    fi
  fi
fi
```
Подключение в ~/.zshrc:
```text
echo 'source ~/path/to/repo/config/zsh/tmux-ghostty.zsh' >> ~/.zshrc
```
```text
source ~/.zshrc
```


### 7. Поведение после настройки

- Запуск Ghostty:
  - стартует zsh,
  - в интерактивной сессии, если терминал - Ghostty и нет активного tmux, автоматически выполняется:
    - ```text tmux attach -t main || tmux new -s main,```
  - в результате сразу попадаем в tmux-сессию main.

- Запуск Terminal.app:
  - переменная TERM_PROGRAM отличается от ghostty,
  - блок автозапуска tmux не срабатывает,
  - получаем обычный zsh без tmux.
 
## 8. Краткое использование
Ниже описано, как работать с этой связкой Ghostty + tmux в реальных сценариях разработки.

### 8.1. Базовая модель tmux
tmux оперирует тремя сущностями:
- **Сессия (session)** - логический рабочий контекст (например: проект, сервер).
- **Окно (window)** - вкладка внутри сессии (часто соответствует “режиму работы”: код, логи, ssh и т.п.).
- **Панель (pane)** - разрез окна на несколько областей экрана (терминалов).
Ghostty поверх всего этого даёт нативные окна/табы macOS, но основная логика работы - внутри tmux.

### 8.2. Сессии tmux
Сессия `main` создаётся/поднимается автоматически при запуске Ghostty.
Дополнительно:
```bash
# создать новую сессию
tmux new -s my-session

# список сессий
tmux ls

# подключиться к существующей сессии
tmux attach -t my-session
tmux attach -t main

# переключиться на другую сессию (изнутри tmux)
tmux switch-client -t my-session
```
Выход из tmux:
- Alt(Option)+d - detach (сессия продолжает жить в фоне, можно подключиться позже).
- Alt(Option)+Q - запрос на полное завершение сессии (kill-session с подтверждением).

### 8.3. Окна (windows)
Окна удобно использовать как “логические вкладки” внутри одного проекта/сессии, например:
- окно 1 - редактор/код,
- окно 2 - сервер/бекенд,
- окно 3 - логи и т.п.
Горячие клавиши:
- Новое окно: Alt(Option)+Enter
- Закрыть окно: Alt(Option)+q (с подтверждением от tmux не требуется, окно закрывается сразу)
- Переключение между окнами:
  - Alt(Option)+1 … Alt(Option)+9 - переход к окну по номеру (нумерация начинается с 1, пересчитывается при закрытии/открытии set -g renumber-windows on)
- Дерево сессий и окон:
  - Alt(Option)+s - открыть дерево (сессии/окна/панели), навигация стрелками, Enter - перейти.
 
### 8.4. Панели (panes) в окне
Панели - это “разделение экрана” внутри одного окна tmux.
Создание сплитов:
- Alt(Option)+h - горизонтальный сплит (экран делится на верх/низ).
- Alt(Option)+v - вертикальный сплит (экран делится на лево/право).
Навигация между панелями:
- Alt(Option)+Left - фокус в панель слева
- Alt(Option)+Right - фокус в панель справа
- Alt(Option)+Up - фокус в панель выше
- Alt(Option)+Down - фокус в панель ниже
Изменение размеров панелей:
- Alt(Option)+Shift+Left - уменьшить панель справа (раздвинуть влево) на 5 колонок
- Alt(Option)+Shift+Right - уменьшить панель слева (раздвинуть вправо) на 5 колонок
- Alt(Option)+Shift+Up - уменьшить панель снизу (раздвинуть вверх) на 3 строки
- Alt(Option)+Shift+Down - уменьшить панель сверху (раздвинуть вниз) на 3 строки
Закрытие панели:
- Alt(Option)+c - закрыть текущую панель (kill-pane)

### 8.5. Копирование и буфер обмена (macOS)
tmux работает в режимах копирования, удобно использовать vi-навигацию.
- Войти в режим копирования:
```bash
Alt(Option)+/   # копирование + поиск вниз
Alt(Option)/?   # копирование + поиск вверх
```
Либо просто Alt(Option)+/ и вручную двигаться по истории.
- В режиме copy-mode-vi:
  - v - начать выделение
  - стрелки / h/j/k/l - двигать курсор и выделение
  - y - скопировать выделенный фрагмент и выйти из режима копирования
Таким образом, копирование сразу попадает в системный буфер обмена macOS (через pbcopy), и текст можно вставить в любое приложение (Cmd+V).

### 8.6. Поиск по истории
В любой момент, внутри tmux:
- Alt(Option)+/ - войти в copy-mode и запросить строку для поиска вниз.
- Alt(Option)+? - то же, но поиск вверх.
Далее:
- ввод строки поиска,
- n / N в vi-режиме - переход к следующему/предыдущему совпадению.

### 8.7. Перезагрузка конфигурации tmux
После изменения ~/.config/tmux/tmux.conf нет необходимости перезапускать tmux-сессию.
Горячая клавиша:
- Alt(Option)+r - выполнить:

### 8.8. Пример рабочего сценария
1. В окне 1:
```shell 
Alt(Option)+v - разделить экран вертикально: слева редактор, справа shell.
Alt(Option)+Down / Alt(Option)+Up / Alt(Option)+Left / Alt(Option)+Right - перемещаться между панелями.
```
3. Alt(Option)+Enter - создать окно 2: запустить backend-сервер, watcher, тесты и т.п.
4. Alt(Option)+3 - создать окно 3: смотреть логи, tail файлов, мониторинг.
5. При необходимости отделиться от сессии: Alt(Option)+d - detach (все процессы продолжают работать).
6. Позже: tmux attach -t main - вернуться в ту же сессию с тем же layout’ом.

Ghostty при этом остаётся "оболочкой" (окна/табы macOS), а вся логика layout’ов и сессий реализуется через tmux.
</details>
