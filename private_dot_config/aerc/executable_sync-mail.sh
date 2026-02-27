#!/bin/bash
# Sync mail: mbsync pull + notmuch reindex
# Used by aerc's check-mail-cmd

export SASL_PATH="/opt/homebrew/opt/cyrus-sasl/lib/sasl2"
export NOTMUCH_CONFIG="${HOME}/.mail/bigid/.notmuch-config"

mbsync bigid 2>&1
notmuch new 2>&1
