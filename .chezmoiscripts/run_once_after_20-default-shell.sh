#!/bin/sh
# Make zsh the login shell, if it isn't already
case "$SHELL" in
    */zsh) ;;
    *) chsh -s "$(command -v zsh)" ;;
esac
