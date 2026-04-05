#import "@preview/touying:0.6.1": config-common, config-page, only, pause, uncover
#import "@preview/metropolyst:0.1.0": (
  alert, brands, config-info, focus-slide as _focus-slide, metropolyst-theme, slide, title-slide,
)
#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0" as db

#let accent(body) = text(fill: rgb("#1c58a1"), body)
#let shadow-image(path, ..args) = layout(avail => context {
  let img = image(path, ..args)
  let (width: w, height: h) = measure(img, width: avail.width)
  box(width: w, height: h, clip: false, stroke: 1pt + black)[
    #for (offset, opacity) in ((7pt, 5%), (5pt, 10%), (3pt, 15%), (1pt, 18%)) {
      place(dx: offset, dy: offset, rect(width: w, height: h, fill: rgb(0, 0, 0, opacity), stroke: none))
    }
    #place(top + left, img)
  ]
})
#let Visigothai = text(font: "Lobster")[#text(fill: rgb("#1c58a1"))[Visigoth]#text(fill: rgb(172, 193, 218))[.ai]]
#let VisigothaiW = text(font: "Lobster")[#text(fill: white)[Visigoth]#text(fill: rgb(172, 193, 218))[.ai]]

#show strong: it => text(weight: 700, it.body)

#let focus-slide(align: horizon + center, body) = _focus-slide(
  align: align,
  config: config-page(
    background: place(top + left, rect(
      width: 100%,
      height: 100%,
      stroke: none,
      fill: tiling(size: (240pt, 240pt), image("assets/app-bkg.svg", width: 240pt, height: 240pt)),
    )),
  ),
  body,
)

#show: metropolyst-theme.with(
  font: ("Roboto",),
  accent-color: rgb("#1c58a1"),
  header-background-color: rgb("#1c58a1"),
  focus-background-color: rgb("#dbdce5"),
  focus-text-color: rgb("#1c58a1"),
  main-background-color: rgb("#ffffff"),
  main-text-color: rgb("#333333"),
  progress-bar-background: rgb(172, 193, 218),
  config-info(
    title: [#text(font: "Lobster", fill: rgb("#1c58a1"))[Visigoth.ai] Data Storage],
    subtitle: [Roast My Tech Stack],
    author: [Dr. Gaurav Manek],
    date: "2026-04-16",
    institution: [Ocellivision, A*STAR; formerly Visigoth.ai],
    logo: image("assets/v-icon.png", height: 1.5em),
  ),
)

// Title slide
#title-slide()

#slide(
  title: [#VisigothaiW is a scheduling tool for two-group events],
  composer: (1fr, 1fr),
)[
  - Two groups of attendees who want to meet *across groups*, not within groups.
  - In use at US universities for visit days, qualifier exams, and welcome courses
  - scales to hundreds of attendees, with:
    - hybrid in-person/remote attendance
    - individual requests
    - departmental policies
    - last-minute changes
][
  #shadow-image("images/demo.png", width: 100%)
]

== The data model

#slide(composer: (1fr, 1fr))[
  1. *Visitors*: one group of attendees, each with personal requests and constraints
  2. *Hosts*: another group of attendees, each with personal requests and constraints
  3. *Meetings*: the currently scheduled meetings between visitors and hosts
][
  #include "figures/data-model.typ"
]

#focus-slide[
  If you are squeamish, look away now.
]


== The (horrifying!) in-memory storage mechanism

#slide(composer: (1fr, 1fr))[
  #include "figures/immutable-meetings.typ"
][#v(1fr)
  Each backend is a *monolithic application* with data kept in-memory.

  The data is an *immutable* collection of *immutable* and *hashable* data structures.

  #pause

  Changes are made by *copying references* into a new collection.

  #v(1fr)
  #text(size: 0.75em)[(Typ: \~200 visitors, \~100 hosts, and \~1000 meetings.)]
]


== The (even more horrifying!) disk storage mechanism

#slide(composer: (1fr, 1fr))[
  #box(width: 100%)[#include "figures/disk-storage.typ"]
][#v(1fr)
  On every change, the *entire* bucket is serialized to JSON.

  #pause

  - and written to SQLite
  - One table: `bucket`, `version`, `data`
  - Read once at *startup*
  - Appended on *every* mutation

  #v(1fr)
]

/*

Why is it bad:
- JSON serialization is expensive, especially for large data

Mitigations for badness:
- `sqlite-compressions` on sqlite: `Brotli` compression for the JSON data, which is very effective.

Why is it not bad:
- JSON serialization is cheap
- SQLite is fast for appends

Why is it secretly brilliant: Immutability! Immutabliity! Immutability!
- Copy-on-write semantics means that we only need to copy references, not data. This means that the cost of mutations is low
- Undo/redo is free, since we can just keep references to old versions
- We calculate a lot of derived data (e.g. meeting counts, schedules), so we don't need to store it in the database. This means that we can keep the database schema simple and flexible. We cache derived data in memory, without worrying about keeping it in sync with the database.
-
*/

// Focus slide for emphasis

== Configuration options, and a long slide title with font size automatically scaled to fit on one line

These are the default styles for *bold*, #alert[alert], and #link("https://typst.app")[hyperlink] text.

View the #link("https://github.com/benzipperer/metropolyst")[documentation] for all configuration options.

=== Example

```typst
#show: metropolyst-theme.with(
  font: ("Roboto",),                       // Modern sans-serif
  font-size: 22pt,                         // Slightly larger text
  accent-color: rgb("#10b981"),            // Emerald accent
  hyperlink-color: rgb("#0ea5e9"),         // Sky blue links
  header-background-color: rgb("#0f172a"), // Slate dark header
)
#set strong(delta: 300)                    // Bolder bold text
```

#text(
  font: "Roboto",
  size: 22pt,
)[These are the custom styles for #text(weight: "bold")[*bold*], #text(fill: rgb("#10b981"))[alert], and #link("https://typst.app")[#text(fill: rgb("#0ea5e9"))[hyperlink]] text.]
