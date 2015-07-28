#!/usr/bin/env bash
#
. helper.sh


#TODO: check bugs with dconf, add check for X11 session
config_gnome(){
    if ask "Do you want to tweak Gnome 3?" Y; then
        apt-get install -y gnome-tweak-tool nautilus-open-terminal

        if ask "Do you want to install some terminal changes and tweaks?" Y; then
            gconftool-2 --type bool --set /apps/gnome-terminal/profiles/Default/scrollback_unlimited true #Terminal -> Edit -> Profile Preferences -> Scrolling -> Scrollback: Unlimited -> Close
            gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/background_darkness 0.85611499999999996 # Not working 100%!
            gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/background_type transparent
        fi

        #TODO: add check for X11 session
        if ask "Enable real transparency?" Y; then
            gsettings set org.gnome.metacity compositing-manager true
        fi

        if ask "Do you want to change Gnome pannel settings?" Y; then
            gsettings set org.gnome.gnome-panel.layout toplevel-id-list "['top-panel']"
            dconf write /org/gnome/gnome-panel/layout/objects/workspace-switcher/toplevel-id "'top-panel'"
            dconf write /org/gnome/gnome-panel/layout/objects/window-list/toplevel-id "'top-panel'"
            dconf write /org/gnome/gnome-panel/layout/toplevels/top-panel/orientation "'top'" #"'right'" # Issue with window-list
            dconf write /org/gnome/gnome-panel/layout/objects/menu-bar/pack-type "'start'"
            dconf write /org/gnome/gnome-panel/layout/objects/menu-bar/pack-index 0
            dconf write /org/gnome/gnome-panel/layout/objects/window-list/pack-type "'start'" # "'center'"
            dconf write /org/gnome/gnome-panel/layout/objects/window-list/pack-index 5 #0
            dconf write /org/gnome/gnome-panel/layout/objects/workspace-switcher/pack-type "'end'"
            dconf write /org/gnome/gnome-panel/layout/objects/clock/pack-type "'end'"
            dconf write /org/gnome/gnome-panel/layout/objects/user-menu/pack-type "'end'"
            dconf write /org/gnome/gnome-panel/layout/objects/notification-area/pack-type "'end'"
            dconf write /org/gnome/gnome-panel/layout/objects/workspace-switcher/pack-index 1
            dconf write /org/gnome/gnome-panel/layout/objects/clock/pack-index 2
            dconf write /org/gnome/gnome-panel/layout/objects/user-menu/pack-index 3
            dconf write /org/gnome/gnome-panel/layout/objects/notification-area/pack-index 4
        fi

        if ask "Enable Auto hide pannels?" N; then
            dconf write /org/gnome/gnome-panel/layout/toplevels/top-panel/auto-hide true
        fi

        if ask "Add top 10 tools to toolbar?" Y; then
            dconf load /org/gnome/gnome-panel/layout/objects/object-10-top/ << EOT
[instance-config]
menu-path='applications:/Kali/Top 10 Security Tools/'
tooltip='Top 10 Security Tools'

[/]
object-iid='PanelInternalFactory::MenuButton'
toplevel-id='top-panel'
pack-type='start'
pack-index=4
EOT
            dconf write /org/gnome/gnome-panel/layout/object-id-list "$(dconf read /org/gnome/gnome-panel/layout/object-id-list | sed "s/]/, 'object-10-top']/")"
        fi

        if ask "Show desktop applet?" Y; then
            dconf load /org/gnome/gnome-panel/layout/objects/object-show-desktop/ << EOT
[/]
object-iid='WnckletFactory::ShowDesktopApplet'
toplevel-id='top-panel'
pack-type='end'
pack-index=0
EOT
            dconf write /org/gnome/gnome-panel/layout/object-id-list "$(dconf read /org/gnome/gnome-panel/layout/object-id-list | sed "s/]/, 'object-show-desktop']/")"
        fi

        if ask "Remove nasty notifications by installing notify-osd?" Y; then
            apt-get install -y notify-osd
        fi

        if ask "Fix icon top 10 shortcut icon?" Y; then
            convert /usr/share/icons/hicolor/48x48/apps/k.png -negate /usr/share/icons/hicolor/48x48/apps/k-invert.png
            #/usr/share/icons/gnome/48x48/status/security-medium.png
        fi

        if ask "Enable only two workspaces" Y; then
            gsettings set org.gnome.desktop.wm.preferences num-workspaces 2 #gconftool-2 --type int --set /apps/metacity/general/num_workspaces 2 #dconf write /org/gnome/gnome-panel/layout/objects/workspace-switcher/instance-config/num-rows 4
            gsettings set org.gnome.shell.overrides dynamic-workspaces false
        fi

        if ask "Smaller title bar?" Y; then
            #sed -i "/title_vertical_pad/s/value=\"[0-9]\{1,2\}\"/value=\"0\"/g" /usr/share/themes/Adwaita/metacity-1/metacity-theme-3.xml
            #sed -i 's/title_scale=".*"/title_scale="small"/g' /usr/share/themes/Adwaita/metacity-1/metacity-theme-3.xml
            gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Droid Bold 10' # 'Cantarell Bold 11'
            gsettings set org.gnome.desktop.wm.preferences titlebar-uses-system-font false
        fi

        if ask "Hide desktop icon?" Y; then
            dconf write /org/gnome/nautilus/desktop/computer-icon-visible false
        fi

        if ask "Restart GNOME panel to apply/take effect (Need to restart xserver)" Y; then
            #killall gnome-panel && gnome-panel& #Still need to logoff!
            mkdir -p ~/.config/gtk-2.0/
            if [ -e ~/.config/gtk-2.0/gtkfilechooser.ini ]; then
                sed -i 's/^.*ShowHidden.*/ShowHidden=true/' ~/.config/gtk-2.0/gtkfilechooser.ini;
            else
                echo -e "\n[Filechooser Settings]\nLocationMode=path-bar\nShowHidden=true\nExpandFolders=false\nShowSizeColumn=true\nGeometryX=66\nGeometryY=39\nGeometryWidth=780\nGeometryHeight=618\nSortColumn=name\nSortOrder=ascending" > ~/.config/gtk-2.0/gtkfilechooser.ini;
            fi
        fi

        if ask "Show Hidden Files: Enabled?" Y; then
            dconf write /org/gnome/nautilus/preferences/show-hidden-files true
        fi

        if ask "Add bookmarks?" N; then
            if [ ! -e ~/.gtk-bookmarks.bkup ]; then
                cp -f ~/.gtk-bookmarks{,.bkup};
            fi
            echo -e 'file:///var/www www\nfile:///usr/share apps\nfile:///tmp tmp\nfile:///usr/local/src/ src' >> ~/.gtk-bookmarks
            #Places -> Location: {/usr/share,/var/www/,/tmp/, /usr/local/src/} -> Bookmarks -> Add bookmark
        fi
    fi
}

install_kde(){
    # How to install KDE Plasma Desktop Environment in Kali Linux:
    apt-get install kali-defaults kali-root-login desktop-base kde-plasma-desktop

    # How to install Netbook KDE Plasma Desktop Environment in Kali Linux:
#    apt-get install kali-defaults kali-root-login desktop-base kde-plasma-netbook

    # How to install Standard Debian selected packages and frameworks in Kali Linux:
#    apt-get install kali-defaults kali-root-login desktop-base kde-standard

    # How to install KDE Full Install in Kali Linux:
#    apt-get install kali-defaults kali-root-login desktop-base kde-full

    # How to remove KDE on Kali Linux:
#    apt-get remove kde-plasma-desktop kde-plasma-netbook kde-standard
}

# Install XFCE4
install_xfce(){
    apt-get install -y kali-defaults kali-root-login desktop-base xfce4 xfce4-places-plugin xfce4-goodies
}

# Configure XFCE4 in Kali Linux
config_xfce(){
    # Set XFCE to as default session manager
    update-alternatives --config x-session-manager

    #
    mkdir -p /root/.config/xfce4/{desktop,menu,panel,xfconf,xfwm4}/
    mkdir -p /root/.config/xfce4/panel/launcher-1{5,6,7,9}
    mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml/
    mkdir -p /root/.themes/

    #
    echo -e "[Wastebasket]\nrow=2\ncol=0\n\n[File System]\nrow=1\ncol=0\n\n[Home]\nrow=0\ncol=0" > /root/.config/xfce4/desktop/icons.screen0.rc
    echo -e "show_button_icon=true\nshow_button_label=false\nlabel=Places\nshow_icons=true\nshow_volumes=true\nmount_open_volumes=false\nshow_bookmarks=true\nshow_recent=true\nshow_recent_clear=true\nshow_recent_number=10\nsearch_cmd=" > /root/.config/xfce4/panel/places-23.rc
    echo -e "card=PlaybackES1371AudioPCI97AnalogStereoPulseAudioMixer\ntrack=Master\ncommand=xfce4-mixer" > /root/.config/xfce4/panel/xfce4-mixer-plugin-24.rc
    echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=Iceweasel\nComment=Browse the World Wide Web\nGenericName=Web Browser\nX-GNOME-FullName=Iceweasel Web Browser\nExec=iceweasel %u\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=iceweasel\nCategories=Network;WebBrowser;\nMimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;\nStartupWMClass=Iceweasel\nStartupNotify=true\nX-XFCE-Source=file:///usr/share/applications/iceweasel.desktop" > /root/.config/xfce4/panel/launcher-15/13684522587.desktop
    echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nExec=exo-open --launch TerminalEmulator\nIcon=utilities-terminal\nStartupNotify=false\nTerminal=false\nCategories=Utility;X-XFCE;X-Xfce-Toplevel;\nOnlyShowIn=XFCE;\nName=Terminal Emulator\nName[en_GB]=Terminal Emulator\nComment=Use the command line\nComment[en_GB]=Use the command line\nX-XFCE-Source=file:///usr/share/applications/exo-terminal-emulator.desktop" > /root/.config/xfce4/panel/launcher-16/13684522758.desktop
    echo -e "[Desktop Entry]\nType=Application\nVersion=1.0\nName=Geany\nName[en_GB]=Geany\nGenericName=Integrated Development Environment\nGenericName[en_GB]=Integrated Development Environment\nComment=A fast and lightweight IDE using GTK2\nComment[en_GB]=A fast and lightweight IDE using GTK2\nExec=geany %F\nIcon=geany\nTerminal=false\nCategories=GTK;Development;IDE;\nMimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/xml;text/html;text/css;text/x-sql;text/x-diff;\nStartupNotify=true\nX-XFCE-Source=file:///usr/share/applications/geany.desktop" > /root/.config/xfce4/panel/launcher-17/13684522859.desktop
    echo -e "[Desktop Entry]\nVersion=1.0\nName=Application Finder\nName[en_GB]=Application Finder\nComment=Find and launch applications installed on your system\nComment[en_GB]=Find and launch applications installed on your system\nExec=xfce4-appfinder\nIcon=xfce4-appfinder\nStartupNotify=true\nTerminal=false\nType=Application\nCategories=X-XFCE;Utility;\nX-XFCE-Source=file:///usr/share/applications/xfce4-appfinder.desktop" > /root/.config/xfce4/panel/launcher-19/136845425410.desktop
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfce4-appfinder" version="1.0">\n <property name="category" type="string" value="All"/>\n <property name="window-width" type="int" value="640"/>\n <property name="window-height" type="int" value="480"/>\n <property name="close-after-execute" type="bool" value="true"/>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-appfinder.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfce4-desktop" version="1.0">\n <property name="backdrop" type="empty">\n <property name="screen0" type="empty">\n <property name="monitor0" type="empty">\n <property name="brightness" type="empty"/>\n <property name="color1" type="empty"/>\n <property name="color2" type="empty"/>\n <property name="color-style" type="empty"/>\n <property name="image-path" type="empty"/>\n <property name="image-show" type="empty"/>\n <property name="last-image" type="empty"/>\n <property name="last-single-image" type="empty"/>\n </property>\n </property>\n </property>\n <property name="desktop-icons" type="empty">\n <property name="file-icons" type="empty">\n <property name="show-removable" type="bool" value="true"/>\n <property name="show-trash" type="bool" value="false"/>\n <property name="show-filesystem" type="bool" value="false"/>\n <property name="show-home" type="bool" value="false"/>\n </property>\n </property>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfce4-keyboard-shortcuts" version="1.0">\n <property name="commands" type="empty">\n <property name="default" type="empty">\n <property name="&lt;Alt&gt;F2" type="empty"/>\n <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="empty"/>\n <property name="XF86Display" type="empty"/>\n <property name="&lt;Super&gt;p" type="empty"/>\n <property name="&lt;Primary&gt;Escape" type="empty"/>\n </property>\n <property name="custom" type="empty">\n <property name="XF86Display" type="string" value="xfce4-display-settings --minimal"/>\n <property name="&lt;Super&gt;p" type="string" value="xfce4-display-settings --minimal"/>\n <property name="&lt;Primary&gt;&lt;Alt&gt;Delete" type="string" value="xflock4"/>\n <property name="&lt;Primary&gt;Escape" type="string" value="xfdesktop --menu"/>\n <property name="&lt;Alt&gt;F2" type="string" value="xfrun4"/>\n <property name="override" type="bool" value="true"/>\n </property>\n </property>\n <property name="xfwm4" type="empty">\n <property name="default" type="empty">\n <property name="&lt;Alt&gt;Insert" type="empty"/>\n <property name="Escape" type="empty"/>\n <property name="Left" type="empty"/>\n <property name="Right" type="empty"/>\n <property name="Up" type="empty"/>\n <property name="Down" type="empty"/>\n <property name="&lt;Alt&gt;Tab" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="empty"/>\n <property name="&lt;Alt&gt;Delete" type="empty"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Down" type="empty"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Left" type="empty"/>\n <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Down" type="empty"/>\n <property name="&lt;Alt&gt;F4" type="empty"/>\n <property name="&lt;Alt&gt;F6" type="empty"/>\n <property name="&lt;Alt&gt;F7" type="empty"/>\n <property name="&lt;Alt&gt;F8" type="empty"/>\n <property name="&lt;Alt&gt;F9" type="empty"/>\n <property name="&lt;Alt&gt;F10" type="empty"/>\n <property name="&lt;Alt&gt;F11" type="empty"/>\n <property name="&lt;Alt&gt;F12" type="empty"/>\n <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Left" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;End" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;Home" type="empty"/>\n <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Right" type="empty"/>\n <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Up" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_1" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_2" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_3" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_4" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_5" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_6" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_7" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_8" type="empty"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_9" type="empty"/>\n <property name="&lt;Alt&gt;space" type="empty"/>\n <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Up" type="empty"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Right" type="empty"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;d" type="empty"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Up" type="empty"/>\n <property name="&lt;Super&gt;Tab" type="empty"/>\n <property name="&lt;Control&gt;F1" type="empty"/>\n <property name="&lt;Control&gt;F2" type="empty"/>\n <property name="&lt;Control&gt;F3" type="empty"/>\n <property name="&lt;Control&gt;F4" type="empty"/>\n <property name="&lt;Control&gt;F5" type="empty"/>\n <property name="&lt;Control&gt;F6" type="empty"/>\n <property name="&lt;Control&gt;F7" type="empty"/>\n <property name="&lt;Control&gt;F8" type="empty"/>\n <property name="&lt;Control&gt;F9" type="empty"/>\n <property name="&lt;Control&gt;F10" type="empty"/>\n <property name="&lt;Control&gt;F11" type="empty"/>\n <property name="&lt;Control&gt;F12" type="empty"/>\n </property>\n <property name="custom" type="empty">\n <property name="&lt;Control&gt;F3" type="string" value="workspace_3_key"/>\n <property name="&lt;Control&gt;F4" type="string" value="workspace_4_key"/>\n <property name="&lt;Control&gt;F5" type="string" value="workspace_5_key"/>\n <property name="&lt;Control&gt;F6" type="string" value="workspace_6_key"/>\n <property name="&lt;Control&gt;F7" type="string" value="workspace_7_key"/>\n <property name="&lt;Control&gt;F8" type="string" value="workspace_8_key"/>\n <property name="&lt;Control&gt;F9" type="string" value="workspace_9_key"/>\n <property name="&lt;Alt&gt;Tab" type="string" value="cycle_windows_key"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Right" type="string" value="right_workspace_key"/>\n <property name="Left" type="string" value="left_key"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;d" type="string" value="show_desktop_key"/>\n <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Left" type="string" value="move_window_left_key"/>\n <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Right" type="string" value="move_window_right_key"/>\n <property name="Up" type="string" value="up_key"/>\n <property name="&lt;Alt&gt;F4" type="string" value="close_window_key"/>\n <property name="&lt;Alt&gt;F6" type="string" value="stick_window_key"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Down" type="string" value="down_workspace_key"/>\n <property name="&lt;Alt&gt;F7" type="string" value="move_window_key"/>\n <property name="&lt;Alt&gt;F9" type="string" value="hide_window_key"/>\n <property name="&lt;Alt&gt;F11" type="string" value="fullscreen_key"/>\n <property name="&lt;Alt&gt;F8" type="string" value="resize_window_key"/>\n <property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>\n <property name="Escape" type="string" value="cancel_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_1" type="string" value="move_window_workspace_1_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_2" type="string" value="move_window_workspace_2_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_3" type="string" value="move_window_workspace_3_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_4" type="string" value="move_window_workspace_4_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_5" type="string" value="move_window_workspace_5_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_6" type="string" value="move_window_workspace_6_key"/>\n <property name="Down" type="string" value="down_key"/>\n <property name="&lt;Control&gt;&lt;Shift&gt;&lt;Alt&gt;Up" type="string" value="move_window_up_key"/>\n <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Down" type="string" value="lower_window_key"/>\n <property name="&lt;Alt&gt;F12" type="string" value="above_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_8" type="string" value="move_window_workspace_8_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_9" type="string" value="move_window_workspace_9_key"/>\n <property name="Right" type="string" value="right_key"/>\n <property name="&lt;Alt&gt;F10" type="string" value="maximize_window_key"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Up" type="string" value="up_workspace_key"/>\n <property name="&lt;Control&gt;F10" type="string" value="workspace_10_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;KP_7" type="string" value="move_window_workspace_7_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;End" type="string" value="move_window_next_workspace_key"/>\n <property name="&lt;Alt&gt;Delete" type="string" value="del_workspace_key"/>\n <property name="&lt;Control&gt;&lt;Alt&gt;Left" type="string" value="left_workspace_key"/>\n <property name="&lt;Control&gt;F12" type="string" value="workspace_12_key"/>\n <property name="&lt;Alt&gt;space" type="string" value="popup_menu_key"/>\n <property name="&lt;Alt&gt;&lt;Shift&gt;Tab" type="string" value="cycle_reverse_windows_key"/>\n <property name="&lt;Shift&gt;&lt;Alt&gt;Page_Up" type="string" value="raise_window_key"/>\n <property name="&lt;Alt&gt;Insert" type="string" value="add_workspace_key"/>\n <property name="&lt;Alt&gt;&lt;Control&gt;Home" type="string" value="move_window_prev_workspace_key"/>\n <property name="&lt;Control&gt;F2" type="string" value="workspace_2_key"/>\n <property name="&lt;Control&gt;F1" type="string" value="workspace_1_key"/>\n <property name="&lt;Control&gt;F11" type="string" value="workspace_11_key"/>\n <property name="override" type="bool" value="true"/>\n </property>\n </property>\n <property name="providers" type="array">\n <value type="string" value="xfwm4"/>\n <value type="string" value="commands"/>\n </property>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfce4-mixer" version="1.0">\n <property name="active-card" type="string" value="PlaybackES1371AudioPCI97AnalogStereoPulseAudioMixer"/>\n <property name="volume-step-size" type="uint" value="5"/>\n <property name="sound-card" type="string" value="PlaybackES1371AudioPCI97AnalogStereoPulseAudioMixer"/>\n <property name="sound-cards" type="empty">\n <property name="PlaybackES1371AudioPCI97AnalogStereoPulseAudioMixer" type="array">\n <value type="string" value="Master"/>\n </property>\n </property>\n <property name="window-height" type="int" value="400"/>\n <property name="window-width" type="int" value="738"/>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-mixer.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfce4-panel" version="1.0">\n <property name="panels" type="uint" value="1">\n <property name="panel-0" type="empty">\n <property name="position" type="string" value="p=6;x=0;y=0"/>\n <property name="length" type="uint" value="100"/>\n <property name="position-locked" type="bool" value="true"/>\n <property name="plugin-ids" type="array">\n <value type="int" value="1"/>\n <value type="int" value="15"/>\n <value type="int" value="16"/>\n <value type="int" value="17"/>\n <value type="int" value="21"/>\n <value type="int" value="23"/>\n <value type="int" value="19"/>\n <value type="int" value="3"/>\n <value type="int" value="24"/>\n <value type="int" value="6"/>\n <value type="int" value="2"/>\n <value type="int" value="5"/>\n <value type="int" value="4"/>\n <value type="int" value="25"/>\n </property>\n <property name="background-alpha" type="uint" value="90"/>\n </property>\n </property>\n <property name="plugins" type="empty">\n <property name="plugin-1" type="string" value="applicationsmenu">\n <property name="button-icon" type="string" value="kali-menu"/>\n <property name="show-button-title" type="bool" value="false"/>\n <property name="show-generic-names" type="bool" value="true"/>\n <property name="show-tooltips" type="bool" value="true"/>\n </property>\n <property name="plugin-2" type="string" value="actions"/>\n <property name="plugin-3" type="string" value="tasklist"/>\n <property name="plugin-4" type="string" value="pager">\n <property name="rows" type="uint" value="1"/>\n </property>\n <property name="plugin-5" type="string" value="clock">\n <property name="digital-format" type="string" value="%R, %A %d %B %Y"/>\n </property>\n <property name="plugin-6" type="string" value="systray">\n <property name="names-visible" type="array">\n <value type="string" value="networkmanager applet"/>\n </property>\n </property>\n <property name="plugin-15" type="string" value="launcher">\n <property name="items" type="array">\n <value type="string" value="13684522587.desktop"/>\n </property>\n </property>\n <property name="plugin-16" type="string" value="launcher">\n <property name="items" type="array">\n <value type="string" value="13684522758.desktop"/>\n </property>\n </property>\n <property name="plugin-17" type="string" value="launcher">\n <property name="items" type="array">\n <value type="string" value="13684522859.desktop"/>\n </property>\n </property>\n <property name="plugin-21" type="string" value="applicationsmenu">\n <property name="custom-menu" type="bool" value="true"/>\n <property name="custom-menu-file" type="string" value="/root/.config/xfce4/menu/top10.menu"/>\n <property name="button-icon" type="string" value="security-medium"/>\n <property name="show-button-title" type="bool" value="false"/>\n <property name="button-title" type="string" value="Top 10"/>\n </property>\n <property name="plugin-19" type="string" value="launcher">\n <property name="items" type="array">\n <value type="string" value="136845425410.desktop"/>\n </property>\n </property>\n <property name="plugin-22" type="empty">\n <property name="base-directory" type="string" value="/root"/>\n <property name="hidden-files" type="bool" value="false"/>\n </property>\n <property name="plugin-23" type="string" value="places"/>\n <property name="plugin-24" type="string" value="xfce4-mixer-plugin"/>\n <property name="plugin-25" type="string" value="showdesktop"/>\n </property>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfce4-settings-editor" version="1.0">\n <property name="window-width" type="int" value="600"/>\n <property name="window-height" type="int" value="380"/>\n <property name="hpaned-position" type="int" value="200"/>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-settings-editor.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xfwm4" version="1.0">\n <property name="general" type="empty">\n <property name="activate_action" type="string" value="bring"/>\n <property name="borderless_maximize" type="bool" value="true"/>\n <property name="box_move" type="bool" value="false"/>\n <property name="box_resize" type="bool" value="false"/>\n <property name="button_layout" type="string" value="O|SHMC"/>\n <property name="button_offset" type="int" value="0"/>\n <property name="button_spacing" type="int" value="0"/>\n <property name="click_to_focus" type="bool" value="true"/>\n <property name="focus_delay" type="int" value="250"/>\n <property name="cycle_apps_only" type="bool" value="false"/>\n <property name="cycle_draw_frame" type="bool" value="true"/>\n <property name="cycle_hidden" type="bool" value="true"/>\n <property name="cycle_minimum" type="bool" value="true"/>\n <property name="cycle_workspaces" type="bool" value="false"/>\n <property name="double_click_time" type="int" value="250"/>\n <property name="double_click_distance" type="int" value="5"/>\n <property name="double_click_action" type="string" value="maximize"/>\n <property name="easy_click" type="string" value="Alt"/>\n <property name="focus_hint" type="bool" value="true"/>\n <property name="focus_new" type="bool" value="true"/>\n <property name="frame_opacity" type="int" value="100"/>\n <property name="full_width_title" type="bool" value="true"/>\n <property name="inactive_opacity" type="int" value="100"/>\n <property name="maximized_offset" type="int" value="0"/>\n <property name="move_opacity" type="int" value="100"/>\n <property name="placement_ratio" type="int" value="20"/>\n <property name="placement_mode" type="string" value="center"/>\n <property name="popup_opacity" type="int" value="100"/>\n <property name="mousewheel_rollup" type="bool" value="true"/>\n <property name="prevent_focus_stealing" type="bool" value="false"/>\n <property name="raise_delay" type="int" value="250"/>\n <property name="raise_on_click" type="bool" value="true"/>\n <property name="raise_on_focus" type="bool" value="false"/>\n <property name="raise_with_any_button" type="bool" value="true"/>\n <property name="repeat_urgent_blink" type="bool" value="false"/>\n <property name="resize_opacity" type="int" value="100"/>\n <property name="restore_on_move" type="bool" value="true"/>\n <property name="scroll_workspaces" type="bool" value="true"/>\n <property name="shadow_delta_height" type="int" value="0"/>\n <property name="shadow_delta_width" type="int" value="0"/>\n <property name="shadow_delta_x" type="int" value="0"/>\n <property name="shadow_delta_y" type="int" value="-3"/>\n <property name="shadow_opacity" type="int" value="50"/>\n <property name="show_app_icon" type="bool" value="false"/>\n <property name="show_dock_shadow" type="bool" value="true"/>\n <property name="show_frame_shadow" type="bool" value="false"/>\n <property name="show_popup_shadow" type="bool" value="false"/>\n <property name="snap_resist" type="bool" value="false"/>\n <property name="snap_to_border" type="bool" value="true"/>\n <property name="snap_to_windows" type="bool" value="false"/>\n <property name="snap_width" type="int" value="10"/>\n <property name="theme" type="string" value="Shiki-Colors-Light-Menus"/>\n <property name="title_alignment" type="string" value="center"/>\n <property name="title_font" type="string" value="Sans Bold 9"/>\n <property name="title_horizontal_offset" type="int" value="0"/>\n <property name="title_shadow_active" type="string" value="false"/>\n <property name="title_shadow_inactive" type="string" value="false"/>\n <property name="title_vertical_offset_active" type="int" value="0"/>\n <property name="title_vertical_offset_inactive" type="int" value="0"/>\n <property name="toggle_workspaces" type="bool" value="false"/>\n <property name="unredirect_overlays" type="bool" value="true"/>\n <property name="urgent_blink" type="bool" value="false"/>\n <property name="use_compositing" type="bool" value="true"/>\n <property name="workspace_count" type="int" value="2"/>\n <property name="wrap_cycle" type="bool" value="true"/>\n <property name="wrap_layout" type="bool" value="true"/>\n <property name="wrap_resistance" type="int" value="10"/>\n <property name="wrap_windows" type="bool" value="true"/>\n <property name="wrap_workspaces" type="bool" value="false"/>\n <property name="workspace_names" type="array">\n <value type="string" value="Workspace 1"/>\n <value type="string" value="Workspace 2"/>\n <value type="string" value="Workspace 3"/>\n <value type="string" value="Workspace 4"/>\n </property>\n </property>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
    echo -e '<?xml version="1.0" encoding="UTF-8"?>\n\n<channel name="xsettings" version="1.0">\n <property name="Net" type="empty">\n <property name="ThemeName" type="empty"/>\n <property name="IconThemeName" type="empty"/>\n <property name="DoubleClickTime" type="int" value="250"/>\n <property name="DoubleClickDistance" type="int" value="5"/>\n <property name="DndDragThreshold" type="int" value="8"/>\n <property name="CursorBlink" type="bool" value="true"/>\n <property name="CursorBlinkTime" type="int" value="1200"/>\n <property name="SoundThemeName" type="string" value="default"/>\n <property name="EnableEventSounds" type="bool" value="false"/>\n <property name="EnableInputFeedbackSounds" type="bool" value="false"/>\n </property>\n <property name="Xft" type="empty">\n <property name="DPI" type="empty"/>\n <property name="Antialias" type="int" value="-1"/>\n <property name="Hinting" type="int" value="-1"/>\n <property name="HintStyle" type="string" value="hintnone"/>\n <property name="RGBA" type="string" value="none"/>\n </property>\n <property name="Gtk" type="empty">\n <property name="CanChangeAccels" type="bool" value="false"/>\n <property name="ColorPalette" type="string" value="black:white:gray50:red:purple:blue:light blue:green:yellow:orange:lavender:brown:goldenrod4:dodger blue:pink:light green:gray10:gray30:gray75:gray90"/>\n <property name="FontName" type="string" value="Sans 10"/>\n <property name="IconSizes" type="string" value=""/>\n <property name="KeyThemeName" type="string" value=""/>\n <property name="ToolbarStyle" type="string" value="icons"/>\n <property name="ToolbarIconSize" type="int" value="3"/>\n <property name="IMPreeditStyle" type="string" value=""/>\n <property name="IMStatusStyle" type="string" value=""/>\n <property name="MenuImages" type="bool" value="true"/>\n <property name="ButtonImages" type="bool" value="true"/>\n <property name="MenuBarAccel" type="string" value="F10"/>\n <property name="CursorThemeName" type="string" value=""/>\n <property name="CursorThemeSize" type="int" value="0"/>\n <property name="IMModule" type="string" value=""/>\n </property>\n</channel>' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
    echo -e '<Menu>\n\t<Name>Top 10</Name>\n\t<DefaultAppDirs/>\n\t<Directory>top10.directory</Directory>\n\t<Include>\n\t\t<Category>top10</Category>\n\t</Include>\n</Menu>' > /root/.config/xfce4/menu/top10.menu
    sed -i 's/^enable=.*/enable=False/' /etc/xdg/user-dirs.conf

    # sed -i 's/^XDG_/#XDG_/; s/^#XDG_DESKTOP/XDG_DESKTOP/;' /root/.config/user-dirs.dirs
    # rm -rf /root/{Documents,Downloads,Music,Pictures,Public,Templates,Videos}/
    #rm -r /root/.cache/sessions/*

    # Install Shiki-Colors-Light-Menus and gnome-brave on demand
#    if ask "Do you want to install Shiki-Colors-Light-Menus and gnome-brave?" Y; then
#        wget http://xfce-look.org/CONTENT/content-files/142110-Shiki-Colors-Light-Menus.tar.gz -O /tmp/Shiki-Colors-Light-Menus.tar.gz
#        tar zxf /tmp/Shiki-Colors-Light-Menus.tar.gz -C /root/.themes/
#        xfconf-query -c xsettings -p /Net/ThemeName -s "Shiki-Colors-Light-Menus"
#        xfconf-query -c xsettings -p /Net/IconThemeName -s "gnome-brave"
#    fi

#    print_status "Enable compositing. Needed to be run with X11!"
#    xfconf-query -c xfwm4 -p /general/use_compositing -s true

    # print_status "Configure Thunar file browser (Need to re-login for effect)"
    # #TODO: check file existance
    # if [ ! -e /root/.config/Thunar/thunarrc ]; then
    #     echo -e "[Configuration]\nLastShowHidden=TRUE" > /root/.config/Thunar/thunarrc;
    # else
    #     sed -i 's/LastShowHidden=.*/LastShowHidden=TRUE/' /root/.config/Thunar/thunarrc;
    # fi
}

install_desktop(){
    if ask "Do you want to install XFCE4?" N; then
        install_xfce

        if ask "Configure XFCE??" Y; then
            config_xfce
        fi
    fi

    if ask "Install KDE?" N; then
        install_kde
    fi

    if ask "Config GNOME?" Y; then
        config_gnome
    fi
}

if [ "${0##*/}" = "desktop.sh" ]; then
    install_desktop
fi