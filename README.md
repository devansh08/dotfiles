# dotfiles

## Setup
- Clone into `~/.dotfiles`
- Run `stow <module>` to create symlink(s) inside `~/`

## Module specific points
### bin
- Add `~/.bin` to `PATH`
- Set `command` in `/etc/greetd/config.toml` to command in `bin/.bin/tuigreet-custom`
- Install custom packages from `PKGBUILD`s in `~/.bin` using `makepkg -sifC`

### Librewolf
- Symlink `.mozilla/librewolf/<profile-id>.default-release/chrome` to `~/.config/librewolf/chrome`

### mime
- Run `update-mime-database ~/.config/mimeapps.list` to update mimelist database
