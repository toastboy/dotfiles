#!/bin/sh
# Make zsh the login shell, if it isn't already
case "$SHELL" in
    */zsh) ;;
    # sudo, because plain chsh asks for the user's password, which cloud images don't have
    *) sudo chsh -s "$(command -v zsh)" "$(id -un)" ;;
esac
