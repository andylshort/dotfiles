// When an app opens a window and no other window of that app exists, send it
// to the app's assigned virtual desktop. Any further windows open wherever
// KWin would normally put them (the current desktop).
//
// Find resource classes with: qdbus-qt6 org.kde.KWin /KWin queryWindowInfo

// Desktop name -> resource classes
const ASSIGNMENTS = {
    "Primary":  ["org.mozilla.firefox", "firefox"],
    "Notes":    ["md.obsidian.Obsidian", "obsidian"],
    "Terminal": ["com.mitchellh.ghostty"],
    "Code":     ["com.microsoft.VSCode", "code"],
    "Chat":     ["com.discordapp.Discord", "discord"],
};

// Windows of the same app arriving shortly after the first (e.g. session
// restore of several Firefox/VS Code windows) follow it to the same desktop.
const GRACE_MS = 5000;

const classToDesktop = {};
for (const name in ASSIGNMENTS)
    for (const cls of ASSIGNMENTS[name])
        classToDesktop[cls.toLowerCase()] = name;

const firstSeen = {};

function appKey(w) {
    return classToDesktop[(w.resourceClass || "").toLowerCase()];
}

function isManaged(w) {
    return w.normalWindow && !w.transient && !w.skipTaskbar && !w.onAllDesktops;
}

function otherWindowExists(w, key) {
    return workspace.windowList().some(o =>
        o !== w && isManaged(o) && appKey(o) === key);
}

workspace.windowAdded.connect(w => {
    if (!isManaged(w))
        return;
    const key = appKey(w);
    if (!key)
        return;

    const now = Date.now();
    const inGrace = firstSeen[key] && now - firstSeen[key] < GRACE_MS;
    if (!inGrace) {
        if (otherWindowExists(w, key))
            return;
        firstSeen[key] = now;
    }

    const desktop = workspace.desktops.find(d => d.name === key);
    if (desktop)
        w.desktops = [desktop];
});
