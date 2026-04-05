#import "@preview/touying:0.6.1": config-common, config-page, only, pause, uncover
#import "@preview/metropolyst:0.1.0": (
  alert, brands, config-info, focus-slide as _focus-slide, metropolyst-theme, slide, title-slide,
)
#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0" as db

#let accent(body) = text(fill: rgb("#1c58a1"), body)
#let callout(body) = block(
  fill: rgb("#ddeeff"),
  width: 100%,
  outset: (x: 8pt, y: 0pt),
  inset: (x: 0pt, y: 16pt),
  radius: 8pt,
)[#body]
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
#let plain-focus-slide(align: horizon + center, body) = _focus-slide(
  align: align,
  config: config-page(fill: rgb("#fcfcfa")),
  body,
)

#show: metropolyst-theme.with(
  font: ("Roboto",),
  accent-color: rgb("#1c58a1"),
  header-background-color: rgb("#1c58a1"),
  focus-background-color: rgb("#dbdce5"),
  focus-text-color: rgb("#1c58a1"),
  main-background-color: rgb("#fcfcfa"),
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

#plain-focus-slide[
  #place(center + horizon, dy: 10pt, image("images/look away now.png", height: 160%))
]

== The (horrifying!) in-memory storage mechanism

#slide(composer: (1fr, 1fr))[
  #include "figures/immutable-meetings.typ"
][#v(1fr)
  Each backend is a *monolithic application* with data kept in-memory.

  The data is an *immutable* collection of *immutable* and *hashable* data structures.

  #pause

  Changes are made by *copying references* into a new collection.

  #pause

  #callout[The tiniest change _(even a single bit)_ results in a *completely new collection*.]

  #v(1fr)
  #text(size: 0.75em)[(Typ: \~200 visitors, \~100 hosts, and \~1000 meetings.)]
]


== The (even more horrifying!) disk storage mechanism

#slide(composer: (1fr, 1fr))[
  #box(width: 100%)[#include "figures/disk-storage.typ"]
][
  On every change, the in-memory bucket is serialized to JSON and written to SQLite.

  All buckets are stored in to the *same table*, with an increasing `version`.

  Read once at *startup*, appended on *every* mutation

  #pause

  #callout[
    Inverts the database paradigm: reads are rare, *writes are frequent*.
  ]
]

== At face value, this is *cursed*.

#slide(composer: (1.6fr, 1fr))[
  #v(1fr)
  *Every mutation requires:*
  - a memory copy of the *entire* collection.
  - serializing the *entire* new collection to JSON
  - writing this to SQLite.
  #v(1fr)
  *Also:*
  - SQLite acts as a non-judgmental append log.
  - The schema is enforced by vibes (Python types)
  - It's immutable, right up until disk space notices.
  - Storage cost scales with history, not just current state.

  #v(1fr)
][
  #place(top + right, dy: 40pt, image("images/cursed.png", height: 110%))
]


== But maybe it's not as bad as it looks?

#slide(composer: (1fr, 1.6fr))[
  #place(top + left, dx: 0pt, dy: -40pt, image("images/duck.png", height: 110%))
][
  *Write volume is manageable:*
  - individual writes are small _(2--8 kB)_
  - total data per event is _\~10 MB_.
    - SQLite can read and append databases of this size in milliseconds.

  #pause

  *Schema enforcement:*
  - Via Typed `@dataclass` structs
    - (Modern equivalent: `Pydantic` models.)
  - No impedance mismatch between in-memory and on-disk formats
  - type checking on deserialization
]


#slide[
  Why it is secretly brilliant:

  - Mutations copy references, not data, so updates stay cheap
  - One immutable source of truth means no denormalization or sync bugs
  - Any pointer is a frozen snapshot, so concurrent reads are trivial
  - Full version history makes rollback and undo effectively free
  - Derived data can be cached aggressively with easy invalidation
  - A single row reproduces the whole application state, which is wonderful for testing
  - The business logic becomes pure and deterministic, which made the core code *much* smaller
]

#focus-slide[
  The quality of a storage design depends more on actual workload than theoretical aesthetics.

  #v(1em)

  Here, trading efficiency for simplicity made the system easier to build, reason about, and maintain.
]
