;; If LuaRocks is installed, make sure that packages installed through it are
;; found (e.g. lgi). If LuaRocks is not installed, do nothing.
(pcall require "luarocks.loader")

;; Standard awesome library
(local gears (require "gears"))
(local awful (require "awful"))
(require "awful.autofocus")
;; Widget and layout library
(local wibox (require "wibox"))
;; Theme handling library
(local beautiful (require "beautiful"))
;; Notification library
(local naughty (require "naughty"))
(local hotkeys-popup (require "awful.hotkeys_popup"))

;; Error handling
;; Check if awesome encountered an error during startup and fell back to
;; another config (This code will only ever execute for the fallback config)
(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :title "Oops, there were errors during startup!"
                   :text awesome.startup_errors}))

;; Handle runtime errors after startup
(do
  (var in-error false)
  (awesome.connect_signal "debug::error" (fn [err]
                                           ;; Make sure we don't go into an endless error loop
                                           (when (not in-error)
                                             (set in-error true)
                                             (naughty.notify {:preset naughty.config.presets.critical
                                                              :title "Oops, an error happened!"
                                                              :text (tostring err)})
                                             (set in-error false)))))

(beautiful.init (.. (gears.filesystem.get_themes_dir) "xresources/theme.lua"))

(local terminal "kitty")
(local editor (or (os.getenv "EDITOR") "nano"))
(local editor-cmd (.. terminal " -e " editor))
(local modkey "Mod4")
(set awful.layout.layouts [awful.layout.suit.floating
                           awful.layout.suit.tile
                           awful.layout.suit.tile.left
                           awful.layout.suit.tile.bottom
                           awful.layout.suit.tile.top
                           awful.layout.suit.fair
                           awful.layout.suit.fair.horizontal
                           awful.layout.suit.spiral
                           awful.layout.suit.spiral.dwindle
                           awful.layout.suit.max
                           awful.layout.suit.max.fullscreen
                           awful.layout.suit.magnifier
                           awful.layout.suit.corner.nw
                           awful.layout.suit.corner.ne
                           awful.layout.suit.corner.sw
                           awful.layout.suit.corner.se])

(fn set-wallpaper [s]
  ;; Wallpaper
  (gears.wallpaper.maximized
    ;; If wallpaper is a function, call it with the screen
    (match (type beautiful.wallpaper)
      "function" (beautiful.wallpaper s)
      _ beautiful.wallpaper)
    s
    true))

;; Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
(screen.connect_signal "property::geometry" set-wallpaper)

;; Wibar
(let [taglist-buttons (gears.table.join
                       (awful.button [] 1 #($1:view_only))
                       (awful.button [modkey] 1 #(when client.focus (client.focus:move_to_tag $1)))
                       (awful.button [] 3 awful.tag.viewtoggle)
                       (awful.button [modkey] 3 #(when client.focus (client.focus:toggle_tag $1)))
                       (awful.button [] 4 #(awful.tag.viewnext $1.screen))
                       (awful.button [] 5 #(awful.tag.viewprev $1.screen)))
      tasklist-buttons (gears.table.join
                        (awful.button [] 1 #(if (= $1 client.focus)
                                                (set $1.minimized true)
                                                ($1:emit_signal "request::activate" "tasklist" {:raise true})))
                        (awful.button [] 4 #(awful.client.focus.byidx 1))
                        (awful.button [] 5 #(awful.client.focus.byidx -1)))]
  ;; Create a wibox for each screen and add it
  (awful.screen.connect_for_each_screen
   (fn [s]
     ;; Wallpaper
     (set-wallpaper s)

     ;; Create a tag table
     (awful.tag ["1" "2" "3" "4" "5" "6" "7" "8" "9"] s (. awful.layout.layouts 1))

     ;; Create a promptbox
     (set s.promptbox (awful.widget.prompt))

     ;; Create an imagebox widget containing an icon for the current layout
     (set s.layoutbox (awful.widget.layoutbox s))
     (s.layoutbox:buttons (gears.table.join
                           (awful.button [] 1 #(awful.layout.inc 1))
                           (awful.button [] 3 #(awful.layout.inc -1))
                           (awful.button [] 4 #(awful.layout.inc 1))
                           (awful.button [] 5 #(awful.layout.inc -1))))

     ;; Create a taglist widget
     (set s.taglist (awful.widget.taglist {:screen s
                                           :filter awful.widget.taglist.filter.all
                                           :buttons taglist-buttons}))

     ;; Create a tasklist widget
     (set s.tasklist (awful.widget.tasklist {:screen s
                                             :filter awful.widget.tasklist.filter.currenttags
                                             :buttons tasklist-buttons}))

     ;; Create a wibox with widgets
     (set s.wibox (awful.wibar {:position "top" :screen s}))
     (s.wibox:setup {:layout wibox.layout.align.horizontal
                     1 {:layout wibox.layout.fixed.horizontal
                        1 (wibox.widget.imagebox beautiful.awesome_icon)
                        2 s.taglist
                        3 s.promptbox}
                     2 s.tasklist
                     3 {:layout wibox.layout.fixed.horizontal
                        1 (wibox.widget.systray)
                        2 (wibox.widget.textclock "%Y-%m-%d %I:%M:%S %p" 1)
                        3 s.layoutbox}}))))

;; Key bindings
(let [globalkeys (gears.table.join
                  (awful.key [modkey] "s" hotkeys-popup.show_help
                             {:description "show help" :group "awesome"})
                  (awful.key [modkey] "Left" awful.tag.viewprev
                             {:description "view previous" :group "tag"})
                  (awful.key [modkey] "Right" awful.tag.viewnext
                             {:description "view next" :group "tag"})
                  (awful.key [modkey] "Escape" awful.tag.history.restore
                             {:description "go back" :group "tag"})

                  (awful.key [modkey] "j" #(awful.client.focus.byidx 1)
                             {:description "focus next by index" :group "client"})
                  (awful.key [modkey] "k" #(awful.client.focus.byidx -1)
                             {:description "focus previous by index" :group "client"})

                  ;; Layout manipulation
                  (awful.key [modkey "Shift"] "j" #(awful.client.swap.byidx 1)
                             {:description "swap with next client by index" :group "client"})
                  (awful.key [modkey "Shift"] "k" #(awful.client.swap.byidx -1)
                             {:description "swap with previous client by index" :group "client"})
                  (awful.key [modkey "Control"] "j" #(awful.screen.focus_relative 1)
                             {:description "focus the next screen" :group "screen"})
                  (awful.key [modkey "Control"] "k" #(awful.screen.focus_relative -1)
                             {:description "focus the previous screen" :group "screen"})
                  (awful.key [modkey] "u" awful.client.urgent.jumpto
                             {:description "jump to urgent client" :group "client"})
                  (awful.key [modkey] "Tab" (fn []
                                              (awful.client.focus.history.previous)
                                              (when client.focus (client.focus:raise)))
                             {:description "go back" :group "client"})

                  ;; Standard program
                  (awful.key [modkey] "Return" #(awful.spawn terminal)
                             {:description "open a terminal" :group "launcher"})
                  (awful.key [modkey "Control"] "r" awesome.restart
                             {:description "reload awesome" :group "awesome"})
                  (awful.key [modkey "Control"] "q" awesome.quit
                             {:description "quit awesome" :group "awesome"})

                  (awful.key [modkey] "l" #(awful.tag.incmwfact 0.05)
                             {:description "increase master width factor" :group "layout"})
                  (awful.key [modkey] "h" #(awful.tag.incmwfact -0.05)
                             {:description "decrease master width factor" :group "layout"})
                  (awful.key [modkey "Shift"] "h" #(awful.tag.incnmaster 1 nil true)
                             {:description "increase the number of master clients" :group "layout"})
                  (awful.key [modkey "Shift"] "l" #(awful.tag.incnmaster -1 nil true)
                             {:description "decrease the number of master clients" :group "layout"})
                  (awful.key [modkey "Control"] "h" #(awful.tag.incncol 1 nil true)
                             {:description "increase the number of columns" :group "layout"})
                  (awful.key [modkey "Control"] "l" #(awful.tag.incncol -1 nil true)
                             {:description "decrease the number of columns" :group "layout"})
                  (awful.key [modkey] "space" #(awful.layout.inc 1)
                             {:description "select next" :group "layout"})
                  (awful.key [modkey "Shift"] "space" #(awful.layout.inc -1)
                             {:description "select previous" :group "layout"})

                  (awful.key [modkey "Control"] "n" #(match (awful.client.restore)
                                                       ;; Focus restored client
                                                       c (c:emit_signal "request::activate" "key.unminimize" {:raise true}))
                             {:description "restore minimized" :group "client"})

                  ;; Prompt
                  (awful.key [modkey] "r" #(: (. (awful.screen.focused) :promptbox) :run)
                             {:description "run prompt" :group "launcher"})

                  (awful.key [modkey] "x" #(awful.prompt.run {:prompt "Run Lua code: "
                                                              :textbox (. (awful.screen.focused) :promptbox :widget)
                                                              :exe_callback awful.util.eval
                                                              :history_path (.. (awful.util.get_cache_dir) "/history_eval")})
                             {:description "lua execute prompt" :group "awesome"})

                  ;; Volume keys
                  (awful.key [] :XF86AudioLowerVolume #(awful.util.spawn "amixer -q -D pulse sset Master 5%-" false))
                  (awful.key [] :XF86AudioRaiseVolume #(awful.util.spawn "amixer -q -D pulse sset Master 5%+" false))
                  (awful.key [] :XF86AudioMute #(awful.util.spawn "amixer -D pulse set Master 1+ toggle" false))

                  ;; Media keys
                  (awful.key [] :XF86AudioPlay #(awful.util.spawn "playerctl play-pause" false))
                  (awful.key [] :XF86AudioNext #(awful.util.spawn "playerctl next" false))
                  (awful.key [] :XF86AudioPrev #(awful.util.spawn "playerctl previous" false)))]
  ;; Set keys
  (root.keys
   ;; Bind all key numbers to tags.
   ;; Be careful: we use keycodes to make it work on any keyboard layout.
   ;; This should map on the top row of your keyboard, usually 1 to 9.
   (accumulate [keys globalkeys
                i _ (ipairs [1 2 3 4 5 6 7 8 9])]
     (gears.table.join
      keys
      ;; View tag only.
      (awful.key [modkey] (.. "#" (+ i 9))
                  #(match (. (awful.screen.focused) :tags i)
                    tag (tag:view_only))
                  {:description (.. "view tag #" i) :group "tag"})
      ;; Toggle tag display
      (awful.key [modkey "Control"] (.. "#" (+ i 9))
                  #(match (. (awful.screen.focused) :tags i)
                    tag (awful.tag.viewtoggle tag))
                  {:description (.. "toggle tag #" i) :group "tag"})
      ;; Move client to tag
      (awful.key [modkey "Shift"] (.. "#" (+ i 9))
                  #(match (?. client :focus :screen :tags i)
                    tag (client.focus:move_to_tag tag))
                  {:description (.. "move focused client to tag #" i) :group "tag"})
      ;; Toggle tag on focused client.
      (awful.key [modkey "Control" "Shift"] (.. "#" (+ i 9))
                  #(match (?. client :focus :screen :tags i)
                    tag (client.focus:toggle_tag tag))
                  {:description (.. "toggle focused client on tag #" i) :group "tag"})))))

;; Mouse bindings
(root.buttons (gears.table.join
               (awful.button [] 4 awful.tag.viewnext)
               (awful.button [] 5 awful.tag.viewprev)))

(let [clientkeys (gears.table.join
                  (awful.key [modkey] "f" (fn [c]
                                            (set c.fullscreen (not c.fullscreen))
                                            (c:raise))
                             {:description "toggle fullscreen" :group "client"})
                  (awful.key [modkey "Shift"] "c" #($1:kill)
                             {:description "close" :group "client"})
                  (awful.key [modkey "Control"] "space" awful.client.floating.toggle
                             {:description "toggle floating" :group "client"})
                  (awful.key [modkey "Control"] "Return" #($1:swap (awful.client.getmaster))
                             {:description "move to master" :group "client"})
                  (awful.key [modkey] "o" #($1:move_to_screen)
                             {:description "move to screen" :group "client"})
                  (awful.key [modkey] "t" #(set $1.ontop (not $1.ontop))
                             {:description "toggle keep on top" :group "client"})
                  ;; The client currently has the input focus, so it cannot be
                  ;; minimized, since minimized clients can't have the focus.
                  (awful.key [modkey] "n" #(set $1.minimized true)
                             {:description "minimize" :group "client"})
                  (awful.key [modkey] "m" (fn [c]
                                            (set c.maximized (not c.maximized))
                                            (c:raise))
                             {:description "(un)maximize" :group "client"})
                  (awful.key [modkey "Control"] "m" (fn [c]
                                                      (set c.maximized_vertical (not c.maximized_vertical))
                                                      (c:raise))
                             {:description "(un)maximize vertically" :group "client"})
                  (awful.key [modkey "Shift"] "m" (fn [c]
                                                    (set c.maximized_horizontal (not c.maximized_horizontal))
                                                    (c:raise))
                             {:description "(un)maximize horizontally" :group "client"}))
      clientbuttons (gears.table.join
                     (awful.button [] 1 #($1:emit_signal "request::activate" "mouse_click" {:raise true}))
                     (awful.button [modkey] 1 (fn [c]
                                                 (c:emit_signal "request::activate" "mouse_click" {:raise true})
                                                 (awful.mouse.client.move c)))
                     (awful.button [modkey] 3 (fn [c]
                                                 (c:emit_signal "request::activate" "mouse_click" {:raise true})
                                                 (awful.mouse.client.resize c))))]
  ;; Rules
  ;; Rules to apply to new clients (through the "manage" signal)
  (set awful.rules.rules
    [;; All clients will match this rule.
     {:rule {}
      :properties {:border_width beautiful.border_width
                   :border_color beautiful.border_normal
                   :focus awful.client.focus.filter
                   :raise true
                   :keys clientkeys
                   :buttons clientbuttons
                   :screen awful.screen.preferred
                   :placement (+ awful.placement.no_overlap awful.placement.no_offscreen)}}

     ;; Floating clients.
     {:rule_any {:instance ["DTA" ;; Firefox addon DownThemAll.
                             "copyq" ;; Includes session name in class.
                             "pinentry"]
                 :class ["Arandr"
                         "Blueman-manager"
                         "Gpick"
                         "Kruler"
                         "MessageWin" ;; kalarm.
                         "Sxiv"
                         "Tor Browser" ;; Needs a fixed window size to avoid fingerprinting by screen size.
                         "Wpa_gui"
                         "veromix"
                         "xtightvncviewer"]

                 ;; Note that the name property shown in xprop might be set slightly after creation of the client
                 ;; and the name shown there might not match defined rules here.
                 :name ["Event Tester"] ;; xev
                 :role ["AlarmWindow" ;; Thunderbird's calendar.
                         "ConfigManager" ;; Thunderbird's about:config.
                         "pop-up"]} ;; e.g. Google Chrome's (detached) Developer Tools.
      :properties {:floating true}}
     ;; Add titlebars to normal clients and dialogs
     {:rule_any {:type ["normal" "dialog"]}
      :properties {:titlebars_enabled true}}]))
     ;; Set Firefox to always map on the tag named "2" on screen 1.
     ;; {:rule {:class "Firefox"}
     ;;  :properties {:screen 1 :tag "2"}}]))

;; Signals
;; Signal function to execute when a new client appears
(client.connect_signal
 "manage"
 (fn [c]
   (if
    ;; Set the windows at the slave,
    ;; i.e. put it at the end of others instead of setting it master.
    (not awesome.startup) (awful.client.setslave c)
    ;; Prevent clients from being unreachable after screen count changes.
    (and (not c.size_hints.user_position)
         (not c.size_hints.program_position)) (awful.placement.no_offscreen c))))

;; Add a titlebar if titlebars_enabled is set to true in the rules.
(client.connect_signal
 "request::titlebars"
 (fn [c]
   ;; Titlebar buttons
   (let [buttons (gears.table.join
                  (awful.button [] 1 (fn []
                                       (c:emit_signal "request::activate" "titlebar" {:raise true})
                                       (awful.mouse.client.move c)))
                  (awful.button [] 3 (fn []
                                       (c:emit_signal "request::activate" "titlebar" {:raise true})
                                       (awful.mouse.client.resize c))))]
     (: (awful.titlebar c) :setup {1 {1 (awful.titlebar.widget.iconwidget c)
                                      : buttons
                                      :layout wibox.layout.fixed.horizontal}
                                   2 {1 {:align "center"
                                         :widget (awful.titlebar.widget.titlewidget c)}
                                      : buttons
                                      :layout wibox.layout.flex.horizontal}
                                   3 {1 (awful.titlebar.widget.floatingbutton c)
                                      2 (awful.titlebar.widget.maximizedbutton c)
                                      3 (awful.titlebar.widget.stickybutton c)
                                      4 (awful.titlebar.widget.ontopbutton c)
                                      5 (awful.titlebar.widget.closebutton c)
                                      :layout (wibox.layout.fixed.horizontal)}
                                   :layout wibox.layout.align.horizontal}))))

;; Enable sloppy focus, so that focus follows mouse
(client.connect_signal "mouse::enter" #($1:emit_signal "request::activate" "mouse_enter" {:raise false}))

(client.connect_signal "focus" #(set $1.border_color beautiful.border_focus))
(client.connect_signal "unfocus" #(set $1.border_color beautiful.border_normal))

;; Launch flameshot screenshot tool
(awful.spawn.once "/usr/bin/flameshot")
