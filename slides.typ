#import "@preview/metropolyst:0.1.0": (
  alert, brands, config-info, focus-slide as _focus-slide, metropolyst-theme, slide, title-slide,
)
#import "@preview/touying:0.6.1": config-page

#let focus-slide(align: horizon + center, body) = _focus-slide(
  align: align,
  config: config-page(
    background: place(top + left, rect(
      width: 100%,
      height: 100%,
      stroke: none,
      fill: tiling(size: (80pt, 80pt), image("assets/app-bkg.svg", width: 80pt, height: 80pt)),
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
    institution: [Ocellivision, A*STAR; Formerly Visigoth.ai],
    logo: image("assets/v-icon.png", height: 1.5em),
  ),
)

// Title slide
#title-slide()

== The Product

This presentation uses the Metropolyst theme with default settings:

- *Aspect ratio:* 16:9
- *Fonts:* Fira Sans throughout
- *Accent color:* Orange (\#eb811b)
- *Header background:* Dark teal (\#23373b)

== My goal
#slide(composer: (3fr, 2fr))[
  === The first column is wider than the second
  Because the code for the layout is

  ```typst
  #slide(composer: (3fr, 2fr))[
    First column content
  ][
    Second column content
  ]
  ```
][
  === For equal width columns
  You can instead do

  ```typst
  #slide[
    First column content
  ][
    Second colum content
  ]
  ```
]

// Focus slide for emphasis
#focus-slide[
  This is a focus slide for emphasis!
]

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
