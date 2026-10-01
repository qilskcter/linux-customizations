# Credits

## Author

- [N0repi](https://github.com/N0repi) · [norepi.dev](https://norepi.dev) — Compact Clock for Plasma 6

## Upstream

Compact Clock is derived from the **Plasma Digital Clock** applet in
[plasma-workspace](https://invent.kde.org/plasma/plasma-workspace)
(reference snapshot: v6.7.3).

Original Digital Clock authors include (non-exhaustive):

- Martin Klapetek
- Heena Mahour
- Sebastian Kügler
- David Edmundson
- Bhushan Shah
- Kai Uwe Broulik
- ivan tkachenko
- Carl Schwan

See SPDX headers in individual source files for per-file copyright.

## Inspiration

Single-line panel layout ideas were inspired by
[Better Inline Clock](https://www.pling.com/p/1245902)
([repo](https://github.com/MarianArlt/kde-plasmoid-betterinlineclock))
(Marian Arlt et al.), a Plasma 5 plasmoid.

## Runtime dependency

This plasmoid imports `org.kde.plasma.private.digitalclock` and
`org.kde.plasma.clock`, which ship with Plasma. Those modules are
**private** APIs and may change between Plasma releases.
