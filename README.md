# dotfiles

## Setup
- Clone into `~/.dotfiles`
- Run `stow <module>` to create symlink(s) inside `~/`

## Module specific points
### bin
- Add `~/.bin` to `PATH`
- Set `command` in `/etc/greetd/config.toml` to command in `bin/.bin/tuigreet-custom`
- Install custom packages from `PKGBUILD`s in `~/.bin` using `makepkg -sifC`

### LibreWolf
- Symlink `.mozilla/librewolf/<profile-id>.default-release/chrome` to `~/.config/librewolf/chrome`

### mime
- Run `update-mime-database ~/.config/mimeapps.list` to update mimelist database

### colors
- Create a new directory under `themes` for the new colorscheme named in the format `<theme_name>-<variant>_<primary_color>`
- Extract colors from a colorscheme in `color_name:color_hex` format into a `input` file under the theme directory
- Enter this content into the input section of the `index.html` page
- Select the colors for the 16 semantic and 16 terminal colors
- Save the output from the webpage into the `output` file
- Run `./set_theme.sh` and select the new colorscheme to generate all the files and symlink the files into `~/.active_theme/`
- Run `node index.js` in `wallpaper-code` to generate a HTML page (`output.html`) that will preview the wallpapers closest matching the color theme
