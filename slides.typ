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

  #pause

  #block(
    fill: rgb("#ddeeff"),
    width: 100%,
    outset: (x: 8pt, y: 0pt),
    inset: (x: 0pt, y: 16pt),
    radius: 8pt,
  )[The tiniest change _(even a single bit)_ results in a *completely new collection*.]

  #v(1fr)
  #text(size: 0.75em)[(Typ: \~200 visitors, \~100 hosts, and \~1000 meetings.)]
]


== The (even more horrifying!) disk storage mechanism

#slide(composer: (1fr, 1fr))[
  #box(width: 100%)[#include "figures/disk-storage.typ"]
][#v(1fr)
  The in-memory collection is persisted to disk via a *versioned data storage* layer on top of SQLite.

  On every change, the *entire* bucket is serialized to JSON.

  #pause

  - Written to one table
  - Read once at *startup*
  - Appended on *every* mutation

  #v(1fr)
]

/*

Why it's horrifying:

- Every mutation serializes the entire collection to JSON and writes to SQLite
- No DB-layer schema enforcement

Why it's less bad than it looks:

- Data is normalized to roughly 2\~3NF, which allows for
- Writes are async and non-blocking — invisible to users
- Writes are batched. All changes in a 15-second window are coalesced into a single write, so the effective write frequency is much lower than the mutation frequency.
  - Support change coalescing trivially: we can just drop writes or rows that correspond to older, minor changes and keep the big ones.
- In practice, 2--8 kB per write (small collections + Brotli via sqlite-compressions)
- Schema enforcement is via application code. All data is stored in `@dataclass` structures with type annotation, and serialization/deserialization directly maps to these structures. (Modern equivalent: `Pydantic` models.)

Why it's secretly brilliant — immutability pays off:

- Mutations copy references, not data — cheap regardless of collection size
- All data is stored from a single source of truth, with no denormalization or duplication — no sync bugs, simple mental model, and easy to reason about data integrity.
- Any list pointer is a consistent frozen view — snapshot isolation for free
- Caching is trivial -- a `weakRef` or `weakDict` allows us to cache derived data with automatic invalidation and minimal memory overhead.
- Full version history in the DB — rollback and undo/redo are just pointer swaps
- No read locks needed — immutable data is always safe to read concurrently
- Derived data (schedules, counts) lives only in memory, invalidated by version comparison — no sync bugs, simple schema
- Derived data can be trivially cached at any level of granularity, with automatic invalidation — no cache coherence bugs
- Any single DB row fully reproduces the application state — trivial regression testing
- Core business logic code is pure and deterministic — easy to test, debug, and reason about. Gone from ~2000 SLOC to ~400 SLOC, with ~95% test coverage.


Moral of the story:

Trading off efficiency for simplicity is often the right call, especially when it comes to complex business logic.

Since we rolled this out to
 Measuring the

immutability is a powerful tool for managing complexity, even at scale. It may seem counterintuitive at first, but it can lead to simpler, more robust, and more maintainable systems in the long run.
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
