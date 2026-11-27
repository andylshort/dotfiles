// Firefox prefs, linked into each installed profile by install.sh. Applied
// at every startup, so changing these in about:config only lasts a session.

// Native-size scrollbars. Firefox draws its own GTK-style scrollbars (not
// Breeze), so KDE settings don't reach it; these are the knobs it has.
// - Ignore `scrollbar-width: thin`, which sites (e.g. Mattermost) use and
//   Firefox on GTK draws far narrower than Chrome
user_pref("layout.css.scrollbar-width-thin.disabled", true);
// - Always show scrollbars instead of overlay ones that appear on hover
user_pref("widget.gtk.overlay-scrollbars.enabled", false);
// - Width in px, if the default still doesn't match Breeze
// user_pref("widget.non-native-theme.scrollbar.size.override", 14);
