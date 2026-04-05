#import "@preview/touying:0.6.1": config-common, config-page, only, pause, uncover
#import "@preview/metropolyst:0.1.0": (
  alert, brands, config-info, focus-slide as _focus-slide, metropolyst-theme, slide, title-slide,
)
#import "@preview/cetz:0.4.2"
#import "@preview/dati-basati:0.1.0" as db
#import "@preview/tiaoma:0.3.0"

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

#slide(composer: (1.8fr, 1fr))[
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
  #place(top + right, dx: 30pt, dy: -20pt, image("images/cursed.png", height: 120%, width: 120%))
]

//
// Denouement: why this isn't actually cursed at all, and is in fact brilliant.
//

#slide(
  config: config-page(
    header: none,
    background: image("images/throw fruit.png", width: 100%, height: 100%, fit: "cover"),
  ),
)[~]


#slide(
  config: config-page(header: none),
  composer: (1.5fr, 1fr),
)[
  #place(center + horizon, dx: 0pt, dy: 0pt, image(
    "images/secretly brilliant.png",
    height: 100%,
    width: 100%,
    fit: "cover",
  ))
][
  #text(size: 1.6em, weight: "semibold")[#emph[What if its...]]
  #pause

  #align(right)[#text(font: "Lobster", size: 1.9em)[secretly brilliant?]]
]


== What if it's secretly brilliant?

#slide(composer: (1fr, 1.8fr))[
  #place(bottom + left, dx: -32pt, dy: 32pt, image("images/duck.png", height: 110%, width: 110%))
][
  *Write volume is manageable:*
  - individual writes are small _(2--8 kB)_
    - Compressed further 2--4x by `sqlite-compression`
  - total data per database is _\~10 MB_.
    - SQLite can read/append our data in milliseconds.

  #pause

  *Schema enforcement:*
  - Via Typed `@dataclass` structs
    - (Modern equivalent: `Pydantic` models.)
  - No impedance mismatch between in-memory and on-disk formats

  #pause
  #v(1fr)
  #callout[
    #align(center)[
      Remember the *Immutability*?
    ]
  ]
]



== Immutability gives us


#slide(composer: (1fr, 1fr), align: top)[
  - Core business logic code is pure and deterministic
    - \~3600 SLOC #sym.arrow \~400 SLOC
    - easy to test, debug, and reason about
      - with \~95% test coverage.
    - *zero* bugs in core scheduling logic since 2020.
  #pause
  - Caching is trivial
    - `weakRef` allows us to cache derived data with automatic invalidation
    - no complex cache coherence checks
  - Cheap copy-on-write

][#pause
  *DB Structure gives us:*
  - Effortless rollback and undo/redo.
  - Reproducible event history for debugging and analytics.
  - Compact history by \"squashing\" small deltas (by deleting them).

  #pause
  #v(1fr)
  #callout[
    #align(center)[
      We've reinvented\
      *Functional Programming!*
    ]
  ]
  #v(1em)
]

#slide(
  config: config-page(
    header: none,
    background: box(width: 100%, height: 100%, clip: true)[
      #place(
        top + center,
        image("images/conclusion.png", width: 100%, height: 100%, fit: "cover"),
      )
    ],
  ),
)[
  #grid(
    columns: (1.2fr, 0.8fr),
    align: (center, left),
    column-gutter: 2.5em,
    [
      *Cursed in theory.*

      *Excellent for the workload.*

      #v(1fr)
    ],
    [ #pause
      #align(center + horizon)[
        #box(fill: color.rgb("#fff"), inset: 1em, radius: .25em, stroke: 2pt + color.rgb("#444"))[
          #link("https://www.gauravmanek.com/lectures/2026/roast-my-tech-stack/")[
            #tiaoma.qrcode(
              "https://www.gauravmanek.com/lectures/2026/roast-my-tech-stack/",
              options: (scale: 4.0),
              width: 8cm,
            )
          ]
          *Scan for more!*
        ]
      ]
    ],
  )
]
