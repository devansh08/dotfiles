if status is-interactive
    set -gx EXA_COLORS 'di=1;38;5;4:ex=1;38;5;40:fi=38;5;255:pi=38;5;6:so=38;5;184:bd=38;5;184:cd=38;5;184:ln=1;38;5;6:or=38;5;9:ur=38;5;39:uw=38;5;39:ux=38;5;39:ue=38;5;39:gr=38;5;34:gw=38;5;34:gx=38;5;34:tr=38;5;172:tw=38;5;172:tx=38;5;172:uu=38;5;117:un=38;5;28:da=38;5;185'
    set -gx HOME '/home/devansh'
    set -gx LSCOLORS 'Gxfxcxdxbxegedabagacad'
    set -gx LS_COLORS 'rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:'
    set -gx MIGRATIONS '/opt/mybatis-migrations'
    set -gx NNN_BMS 'h:/home/devansh;m:/run/media/devansh/;d:/home/devansh/Downloads/;w:/home/devansh/Win/Users/Devansh/'
    set -gx NNN_FCOLORS 'B8B80428000606000906B806'
    set -gx NNN_FIFO '/tmp/nnn.fifo'
    set -gx NNN_PLUG 'x:-!./$nnn&*;u:!unp -U "$nnn";m:-!xargs -0 xdg-open < '
    set -gx NNN_SEL '/tmp/.sel'
    set -x PATH $PATH '/home/devansh/Android/cmdlin-tools/latest/bin' '/home/devansh/Android/emulator' '/home/devansh/Android/platform-tools' '/home/devansh/.yarn/bin' '/home/devansh/Scripts'

    fzf_configure_bindings --directory=\cf --git_log=\cl --git_status=\cs --history=\cr --variables=\cx --processes=\cp
end
