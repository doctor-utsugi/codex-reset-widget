.pragma library

var FORECAST_URL = "https://codex-reset.com/api/forecast";

function ago(ms) {
    var minutes = Math.max(0, Math.floor(ms / 60000));
    if (minutes < 60) return minutes + "m ago";
    var hours = Math.floor(minutes / 60);
    if (hours < 24) return hours + "h ago";
    return Math.floor(hours / 24) + "d ago";
}

function until(ms) {
    var minutes = Math.max(1, Math.ceil(ms / 60000));
    if (minutes < 60) return "in " + minutes + "m";
    var hours = Math.floor(minutes / 60);
    if (hours < 24) return "in " + hours + "h " + (minutes % 60) + "m";
    return "in " + Math.round(hours / 24) + "d";
}

// Mirrors currentOfficialSignal/actionableOfficialSignal in the site's home-signal.js:
// an announcement counts until its window closes or a reset lands after it.
function announcement(forecast, now) {
    var signal = forecast.official_signal;
    if (!signal || !String(signal.summary || "").trim()) return null;
    var at = Date.parse(signal.at || "");
    if (!isFinite(at) || at > now) return null;
    if (Date.parse(forecast.last_reset_at || "") > at) return null;
    var win = signal.window;
    var endAt = Date.parse(win && win.end_at || "");
    if (win && !(isFinite(endAt) && now < endAt)) return null;
    var startAt = Date.parse(win && win.start_at || "");
    var label = String(win && win.label || "").trim();
    var timed = label && !/timing unspecified/i.test(label);
    return { target: timed ? (isFinite(startAt) && startAt > now ? startAt : endAt) : NaN };
}

// Returns what the panel and the popup show: text, state (announced/hinted/quiet) and details.
function summarize(forecast, now) {
    var lastReset = Date.parse(forecast.last_reset_at || "");
    var lastText = isFinite(lastReset) ? ago(now - lastReset) : "?";
    var chance = forecast.probabilities ? forecast.probabilities.rounded_24h : null;
    var ann = announcement(forecast, now);
    if (ann) {
        var next = isFinite(ann.target) ? until(ann.target - now) : "today";
        return { text: next, state: "announced", next: next, last: lastReset, chance: chance };
    }
    var score = forecast.signal_score;
    var hinted = score && score.band === "tease" && score.value >= 50;
    return { text: lastText, state: hinted ? "hinted" : "quiet", next: hinted ? "hinted" : "not announced", last: lastReset, chance: chance };
}
