---
title: "Pinentry Documentation"
description: "Pinentry usage, the Assuan protocol and implementation details."
summary: "Pinentry usage, the Assuan protocol and implementation details."
date: 2023-12-18T01:01:11+01:00
tags:  ["gnupg", "pinentry", "security", "encryption"]
keywords: ["gnupg", "pinentry", "security", "encryption"]
# featureAlt:
# draft:  true
aliases: ["/docs/gnupg/pinentry/documentation/"]
---

## Introduction

This manual documents how to use the PINENTRY and its protocol.

The PINENTRY is a small GUI application used to enter PINs or
passphrases.  It is usually invoked by GPG-AGENT (*note Invoking the
gpg-agent: (gnupg)Invoking GPG-AGENT, for details).

PINENTRY comes in several flavors to fit the look and feel of the
used GUI toolkit: A GTK+ based one named `pinentry-gtk`; a QT based one
named `pinentry-qt`; and, two non-graphical ones `pinentry-curses`,
which uses curses, and `pinentry-tty`, which doesn't require anything
more than a simple terminal.  Not all of them are necessarily available
on your installation.  If curses is supported on your system, the
GUI-based flavors fall back to curses when the `DISPLAY` variable is not
set.

## How to use the PINENTRY

You may run PINENTRY directly from the command line and pass the
commands according to the Assuan protocol via stdin/stdout.

Here is a list of options supported by all flavors of pinentry:

`--version`: Print the program version and licensing information.

`--help`: Print a usage message summarizing the most useful command line options.

`--debug` `-d`: Turn on some debugging.  Mostly useful for the maintainers. Note that this may reveal sensitive information like the entered passphrase.

`--no-global-grab` `-g`: Grab the keyboard only when the window is focused. Use this option if you are debugging software using the PINENTRY; otherwise you may not be able to to access your X session anymore (unless you have other means to connect to the machine to kill the PINENTRY).

`--parent-wid N`: Use window ID N as the parent window for positioning the window. Note, that this is not fully supported by all flavors of PINENTRY.

`--timeout SECONDS`: Give up waiting for input from the user after the specified number of seconds and return an error. The error returned is the same as if the Cancel button was selected. To disable the timeout and wait indefinitely, set this to 0, which is the default.

`--display STRING` `--ttyname STRING` `--ttytype STRING` `--lc-ctype STRING` `--lc-messages STRING`: These options are used to pass localization information to PINENTRY. They are required because PINENTRY is usually called by some background process which does not have any information about the locale and terminal to use.  It is also possible to pass these options using Assuan protocol options.

## Front Ends

There are several different flavors of PINENTRY.  Concretely, there are
Gtk+2, Qt 4/5, TQt, EFL, FLTK, Gnome 3, Emacs, curses and tty variants.
These different implementations provide higher levels of integration
with a specific environment.  For instance, the Gnome 3 PINENTRY uses
Gnome 3 widgets to display the prompts.  For Gnome 3 users, this higher
level of integration provides a more consistent aesthetic.  However,
this comes at a cost.  Because this PINENTRY uses so many components,
there is a larger chance of a failure.  In particular, there is a larger
chance that the passphrase is saved in memory and that memory is exposed
to an attacker (consider the OpenSSL Heartbeat vulnerability).

To understand how many components touch the passphrase, consider
again the Gnome 3 implementation.  When a user presses a button on the
keyboard, the key is passed from the kernel to the X server to the
toolkit (Gtk+) and to the actual text entry widget.  Along the way, the
key is saved in memory and processed.  In fact, the key presses are
probably read using standard C library functions, which buffer the
input.  None of this code is careful to make sure the contents of the
memory are not leaked by keeping the data in unpagable memory and wiping
it when the buffer is freed.  However, even if they did, there is still
the problem that when a computer hibernates, the system writes unpagable
memory to disk anyway.  Further, many installations are virtualized
(e.g., running on Xen) and have little control over their actual
environment.

The curses variant uses a significant smaller software stack and the
tty variant uses an even smaller one.  However, if they are run in an
X terminal, then a similar number of components are handling the
passphrase as in the Gnome 3 case!  Thus, to be most secure, you need to
direct GPG Agent to use a fixed virtual console.  Since you need to
remain logged in for GPG Agent to use that console, you should run there
and have `screen` or `tmux` lock the tty.

The Emacs pinentry implementation interacts with a running Emacs
session and directs the Emacs instance to display the passphrase prompt.
Since this doesn't work very well if there is no Emacs running, the
generic PINENTRY backend checks if a PINENTRY-enabled Emacs should be
used.  Specifically, it looks to see if the `INSIDE_EMACS` variable is
set and then attempts to establish a connection to the specified
address.  If this is the case, then instead of, e.g., `pinentry-gtk2`
displaying a Gtk+2 pinentry, it interacts with the Emacs session.  This
functionality can be explicitly disabled by passing
`--disable-inside-emacs` to `configure` when building PINENTRY.

Having Emacs get the passphrase is convenient, however, it is a
significant security risk.  Emacs is a huge program, which doesn't
provide any process isolation to speak of.  As such, having it handle
the passphrase adds a huge chunk of code to the user's trusted computing
base.  Because of this concern, Emacs doesn't enable this by default,
unless the `allow-emacs-pinentry` option is explicitly set in his or her
`.gnupg/gpg-agent.conf` file.

Similar to the inside-emacs check, the PINENTRY frontends check
whether the `DISPLAY` variable is set and a working X server is
available.  If this is not the case, then they fallback to the curses
front end.  This can also be disabled by passing
`--disable-fallback-curses` to `configure` at build time.


## PINENTRY's Assuan Protocol


The PINENTRY should never service more than one connection at once.  It
is reasonable to exec the PINENTRY prior to a request.

The PINENTRY does not need to stay in memory because the GPG-AGENT
has the ability to cache passphrases.  The usual way to run the PINENTRY
is by setting up a pipe (not a socket) and then fork/exec the PINENTRY.
The communication is then done by means of the protocol described here
until the client is satisfied with the result.

Although it is called a PINENTRY, it allows entering reasonably long
strings (strings that are up to 2048 characters long are supported by
every pinentry).  The client using the PINENTRY has to check for
correctness.

Note that all strings are expected to be encoded as UTF-8; PINENTRY
takes care of converting it to the locally used codeset.  To include
linefeeds or other special characters, you may percent-escape them
(e.g., a line feed is encoded as `%0A`, the percent sign itself is
encoded as `%25`, etc.).

The following is a list of supported commands:

### Set the timeout before returning an error

- C: SETTIMEOUT 30
- S: OK

### Set the descriptive text to display

- C: SETDESC Enter PIN for Richard Nixon `<nobody@trickydicky.gov>`
- S: OK

### Set the prompt to show

When asking for a PIN, set the text just before the widget for passphrase entry.

- C: SETPROMPT PIN:
- S: OK

You should use an underscore in the text only if you know that a modern version of pinentry is used.  Modern versions underline the next character after the underscore and use the first such underlined character as a keyboard accelerator.  Use a double underscore to escape an underscore.

### Set the window title

This command may be used to change the default window title.  When using this feature you should take care that the window is still identifiable as the pinentry.

- C: SETTITLE Tape Recorder Room
- S: OK

### Set the button texts
There are three texts which should be used to override the English
defaults:

To set the text for the button signaling confirmation (in UTF-8).
See SETPROMPT on how to use an keyboard accelerator.

- C: SETOK Yes
- S: OK

To set the text for the button signaling cancellation or
disagreement (in UTF-8). See `SETPROMPT` on how to use an keyboard
accelerator.

- C: SETCANCEL No
- S: OK

In case three buttons are required, use the following command to
set the text (UTF-8) for the non-affirmative response button.  The
affirmative button text is still set using SETOK and the CANCEL
button text with SETCANCEL. See SETPROMPT on how to use an keyboard
accelerator.

- C: SETNOTOK Do not do this
- S: OK

### Set the Error text

This is used by the client to display an error message.  In
contrast to the other commands, the error message is automatically
reset with a GETPIN or CONFIRM, and is only displayed when asking
for a PIN.

- C: SETERROR Invalid PIN entered - please try again
- S: OK

### Enable a passphrase quality indicator
Adds a quality indicator to the GETPIN window.  This indicator is
updated as the passphrase is typed.  The clients needs to implement
an inquiry named "QUALITY" which gets passed the current passphrase
(percent-plus escaped) and should send back a string with a single
numerical value between -100 and 100.  Negative values will be
displayed in red.

- C: SETQUALITYBAR
- S: OK

If a custom label for the quality bar is required, just add that
label as an argument as a percent-escaped string.  You will need
this feature to translate the label because PINENTRY has no
internal gettext except for stock strings from the toolkit library.

If you want to show a tooltip for the quality bar, you may use

- C: SETQUALITYBAR_TT string
- S: OK

With STRING being a percent escaped string shown as the tooltip.

### Enable enforcement of passphrase constraints

This will make the pinentry check whether the new passphrase
entered by the user satisfies the passphrase constraints before
passing the passphrase to gpg-agent and closing the pinentry.  This
gives the user the chance to modify the passphrase until the
constraints are satisfied without retyping the passphrase.

- C: OPTION constraints-enforce
- S: OK

To inform the user about the constraints a short hint and a longer
hint can be set using

- C: OPTION constraints-hint-short=At least 8 characters
- S: OK
- C: OPTION constraints-hint-long=The passphrase must ...
- S: OK

Additionally, a title for the dialog showing details in case of
unsatisfied constraints can be set using

- C: OPTION constraints-error-title=Passphrase Not Allowed
- S: OK

All strings have to be percent escaped.

### Enable an action for generating a passphrase

Adds an action for generating a random passphrase to the GETPIN
window.  The action is only available when asking for a new
passphrase, i.e.  if SETREPEAT has been called.

- C: SETGENPIN Suggest
- S: OK

If you want to provide a tooltip for the action, you may use

- C: SETGENPIN_TT Suggest a random passphrase
- S: OK

### Enable passphrase formatting

Passphrase formatting will group the characters of the passphrase
into groups of five characters separated by non-breaking spaces or
a similar separator.  This is useful in combination with passphrase
generation to make the generated passphrase easier readable.

- C: OPTION formatted-passphrase
- S: OK

Note: If passphrase formatting is enabled, then, depending on the
concrete pinentry, all occurrences of the character used as
separator may be stripped from the entered passphrase.

To provide a hint for the user that is shown if passphrase
formatting is enabled use

- C: OPTION formatted-passphrase-hint=Blanks are not part of the passphrase.
- S: OK

### Ask for a PIN

The meat of this tool is to ask for a passphrase of PIN, it is done
with this command:

- C: GETPIN
- S: D no more tapes
- S: OK

Note that the passphrase is transmitted in clear using standard
data responses.  Expect it to be in UTF-8.

### Ask for confirmation

To ask for a confirmation (yes or no), you can use this command:

- C: CONFIRM
- S: OK

The client should use SETDESC to set an appropriate text before
issuing this command, and may use SETPROMPT to set the button
texts.  The value returned is either OK for YES or the error code

### ASSUAN_Not_Confirmed.

### Show a message
To show a message, you can use this command:

- C: MESSAGE
- S: OK

alternatively you may add an option to confirm:

- C: CONFIRM --one-button
- S: OK

The client should use SETDESC to set an appropriate text before
issuing this command, and may use SETOK to set the text for the
dismiss button.  The value returned is OK or an error message.

### Set the output device

When using X, the PINENTRY program must be invoked with an
appropriate`DISPLAY`environment variable or the`--display'
option.

When using a text terminal:

- C: OPTION ttyname=/dev/tty3
- S: OK
- C: OPTION ttytype=vt100
- S: OK
- C: OPTION lc-ctype=de_DE.UTF-8
- S: OK

The client should use the`ttyname`option to set the output TTY
file name, the`ttytype`option to the`TERM`variable appropriate
for this tty and`lc-ctype`to the locale which defines the
character set to use for this terminal.

### Set the default strings

To avoid having translations in Pinentry proper, the caller may set
certain translated strings which are used by PINENTRY as default
strings.

- C: OPTION default-ok=_Korrekt
- S: OK
- C: OPTION default-cancel=Abbruch
- S: OK
- C: OPTION default-prompt=PIN eingeben:
- S: OK

The strings are subject to accelerator marking, see SETPROMPT for
details.

### Passphrase caching

Some environments, such as GNOME, cache passwords and passphrases.
The PINENTRY should only use an external cache if the
`allow-external-password-cache`option was set and a stable key
identifier (using SETKEYINFO) was provided.  In this case, if the
passphrase was read from the cache, the PINENTRY should send the
`PASSWORD_FROM_CACHE` status message before returning the
passphrase.  This indicates to GPG Agent that it should not
increment the passphrase retry counter.

- C: OPTION allow-external-password-cache
- S: OK
- C: SETKEYINFO key-grip
- S: OK
- C: getpin
- S: S PASSWORD_FROM_CACHE
- S: D 1234
- S: OK

Note: if`allow-external-password-cache`is not specified, an
external password cache must not be used: this can lead to subtle
bugs.  In particular, if this option is not specified, then GPG
Agent does not recognize the`PASSWORD_FROM_CACHE`status message
and will count trying a cached password against the password retry
count.  If the password retry count is 1, then the user will never
have the opportunity to correct the cached password.

Note: it is strongly recommended that a pinentry supporting this
feature provide the user an option to enable it manually.  That is,
saving a passphrase in an external password manager should be
opt-in.

The key identifier provided SETKEYINFO must be considered opaque
and may change in the future.  It currently has the form
`X/HEXSTRING` where `X` is either`n`,`s`, or`u`.  In the former
two cases, the HEXSTRING corresponds to the key grip.  The key grip
is not the OpenPGP Key ID, but it can be mapped to the key using
the following:

```bash
gpg2 --with-keygrip --list-secret-keys
```
and searching the output for the key grip.  The same command-line
options can also be used with gpgsm.


## Implementation Details


The pinentry source code can be divided into three categories.  There is
a backend module, which lives in`pinentry/`, there are utility
functions, e.g., in`secmem/`, and there are various frontends.

All of the low-level logic lives in the backend.  This frees the
frontends from having to implement, e.g., the Assuan protocol.  When the
backend receives an option, it updates the state in a`pinentry_t`
struct.  The frontend is called when the client either calls`GETPIN`,
`CONFIRM` or `MESSAGE`.  In these cases, the backend invokes the
`pinentry_cmd_handler`, which is passed the`pinentry_t`struct.

When the callback is invoked, the frontend should create a window
based on the state in the`pinentry_t`struct.  For instance, the title
to use for the dialog's window (if any) is stored in the`title`field.
If the is`NULL`, the frontend should choose a reasonable default value.
(Default is not always provided, because different tool kits and
environments have different reasonable defaults.)

The widget needs to support a number of different interactions with
the user.  Each of them is described below.

### Passphrase Confirmation

When creating a new key, the passphrase should be entered twice.
The client (typically GPG Agent) indicates this to the PINENTRY by
invoking`SETREPEAT`.  In this case, the backend sets the
`repeat_passphrase` field to a copy of the passed string.  The
value of this field should be used to label a second text input.

It is the frontend's responsibility to check that the passwords
match.  If they don't match, the frontend should display an error
message and continue to prompt the user.

If the passwords do match, then, when the user presses the okay
button, the`repeat_okay`field should be set to`1`(this causes
the backend to emit the`S PIN_REPEATED`status message).

### Message Box

Sometimes GPG Agent needs to display a message.  In this case, the
`pin` variable is`NULL`.

At the Assuan level, this mode is selected by using either the
`MESSAGE` or the `CONFIRM`command instead of the`GETPIN`command.
The`MESSAGE`command never shows the cancel or an other button.
The same holds for`CONFIRM`if it was passed the "-one-button"
argument.  If`CONFIRM`was not passed this argument, the dialog
for`CONFIRM`should show both the`ok`and the`cancel`buttons
and optionally the`notok`button.  The frontend can determine
whether the dialog is a one-button dialog by inspecting the
`one_button` variable.

### Passphrase Entry

If neither of the above cases holds, then GPG Agent is simply
requesting the passphrase.  In this case, the`ok`and`cancel'
buttons should be displayed.

The layout of the three variants is quite similar.  Here are the
relevant elements that describe the layout:

#### title

The window's title.

#### description

The reason for the dialog.  When requesting a passphrase, this
describes the key.  When showing a message box, this is the message
to show.

#### error

If GPG Agent determines that the passphrase was incorrect, it will
call`GETPIN`again (up to a configurable number of times) to again
prompt the user.  In this case, this variable contains a
description of the error message.  This text should typically be
highlighted in someway.

#### prompt, default-prompt

The string to associate with the passphrase entry box.

There is a subtle difference between`prompt`and`default-prompt`.
`default-prompt`means that a stylized prompt (e.g., an icon
suggesting a prompt) may be used. `prompt`means that the entry's
meaning is not consistent with such a style and, as such, no icon
should be used.

If both variables are set, the`prompt`variant takes precedence.

#### repeat_passphrase

The string to associate with the second passphrase entry box.  The
second passphrase entry box should only be shown if this is not
`NULL`.

#### ok, default-ok

The string to show in the`ok`button.

If there are any`_`characters, the following character should be
used as an accelerator.  (A double underscore means a plain
underscore should be shown.)  If the frontend does not support
accelerators, then the underscores should be removed manually.

There is a subtle difference between`ok`and`default-ok`.
`default-ok` means that a stylized OK button should be used.  For
instance, it could include a check mark. `ok`means that the
button's meaning is not consistent with such an icon and, as such,
no icon should be used.  Thus, if the`ok`button should have the
text "No password required" then`ok`should be used because a
check mark icon doesn't make sense.

If this variable is`NULL`, the frontend should choose a reasonable
default.

If both variables are set, the`ok`variant takes precedence.

#### cancel, default-cancel

Like the`ok`and`default-ok`buttons except these strings are
used for the cancel button.

This button should not be shown if`one_button`is set.

`default-notok`Like the`default-ok`button except this string is
used for the other button.

This button should only be displayed when showing a message box.
If these variables are`NULL`or`one_button`is set, this button
should not be displayed.

#### quality_bar

If this is set, a widget should be used to show the password's
quality.  The value of this field is a label for the widget.

Note: to update the password quality, whenever the password
changes, call the`pinentry_inq_quality`function and then update
the password quality widget correspondingly.

#### quality_bar_tt

A tooltip for the quality bar.

#### constraints_enforce

If this is not 0, then passphrase constraints are enforced by
gpg-agent.  In this case pinentry can use the
`pinentry_inq_checkpin`function for checking whether the new
passphrase satisfies the constraints before passing it to
gpg-agent.

#### constraints_hint_short

A short translated hint for the user with the constraints for new
passphrases to be displayed near the passphrase input field.

#### constraints_hint_short
A longer translated hint for the user with the constraints for new
passphrases to be displayed for example as tooltip.

#### constraints_error_title

A short translated title for an error dialog informing the user
about unsatisfied passphrase constraints.

#### genpin_label

If this is set, a generate action should be shown.  The value of
this field is a label for the action.

Note: Call the`pinentry_inq_genpin`function to request a randomly
generated passphrase.

#### genpin_tt

The tooltip for the generate action.

#### formatted_passphrase

If this is not 0, then passphrase formatting should be enabled.  If
it is enabled, then the unmasked passphrase should be grouped into
groups of five characters separated by non-breaking spaces or a
similar separator.

To simplify the implementation all occurrences of the character
used as separator can be stripped from the entered passphrase, if
formatting is enabled.

#### formatted_passphrase_hint

A hint to be shown if passphrase formatting is enabled.  It should
be shown near the passphrase input field.

#### default_pwmngr
If`may_cache_password`and`keyinfo`are set and the user
consents, then the PINENTRY may cache the password with an external
manager.  Note: getting the user's consent is essential, because
password managers often provide a different level of security.  If
the above condition is true and`tried_password_cache`is false,
then a check box with the specified string should be displayed.
The check box must default to off.

#### default-cf-visi

The string to show with a question if you want to confirm that the
user wants to change the visibility of the password.

#### default-tt-visi

Tooltip for an action that would reveal the entered password.

#### default-tt-hide

Tooltip for an action that would hide the password revealed by the
action labeld with`default-tt-visi`

#### default-capshint

A hint to be shown if Caps Lock is on.

When the handler is done, it should store the passphrase in`pin`, if
appropriate.  This variable is allocated in secure memory.  Use
`pinentry_setbufferlen`to size the buffer.

The actual return code is dependent on whether the dialog is in
message mode or in passphrase mode.

If the dialog is in message mode and the user pressed ok, return 1.
Otherwise, return 0.  If an error occurred, indicate this by setting it
in`specific_err`or setting`locale_err`to`1`(for locale specific
errors).  If the dialog was canceled, then the handler should set the
`canceled`variable to`1`.  If the not ok button was pressed, don't do
anything else.

If the dialog is in passphrase mode return`1`if the user entered a
password and pressed ok.  If an error occurred, return`-1`and set
`specific_err` or `locale_err`, as above.  If the user canceled the
dialog box, return`-1`.

If the window was closed, then the handler should set the
`close_button` variable and otherwise act as if the cancel button was
pressed.


{{< alert "circle-info" >}}
This wall of text is a Markdown formatted copy of the
[original documentation](https://git.gnupg.org/cgi-bin/gitweb.cgi?p=pinentry.git;a=blob;f=doc/pinentry.texi;h=a05bdb11716e46882bbd981d343064c06b85afe4;hb=HEAD).
{{< /alert >}}