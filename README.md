# Codex Reset widget

A Plasma 6 panel widget that shows when the next Codex usage reset is, or, when
none is announced, how long ago the last one was. Data comes from
[codex-reset.com](https://codex-reset.com/)'s `/api/forecast`, polled every 5 minutes.

Panel text (the dot is a badge on the OpenAI logo):

- `● in 3h 12m` (red): a reset is announced with a time window.
- `● today` (red): announced without a time.
- `● 5h ago` (orange): nothing announced, but Tibo is hinting.
- `● 5h ago` (grey): nothing announced.

Clicking it shows the next reset, the last reset and the 24h chance; clicking
the popup opens the site.

## Install

    ./install.sh

Then add "Codex Reset" to a panel.

The OpenAI logo is from [Simple Icons](https://simpleicons.org/) (CC0); it is a trademark of OpenAI.
