#box(
  width: 10cm,
  height: 9cm,
)[
  #align(center + horizon)[
    #stack(
      dir: ttb,
      spacing: 0.25em,
      [
        #stack(
          dir: ttb,
          spacing: 0.25em,
          [
            #block(
              width: 100%,
              inset: 10pt,
              radius: 8pt,
              fill: rgb("#1c58a1"),
            )[
              #align(center + horizon)[#text(fill: white, weight: 600, size: 20pt)[Pure Logic]]
            ]
          ],
          [#align(center + horizon)[#text(fill: rgb("#666"))[#sym.arrow.b]]],
          [
            #block(
              width: 100%,
              inset: 10pt,
              radius: 8pt,
              fill: rgb("#ddeeff"),
            )[
              #align(center + horizon)[#text(fill: rgb("#1c58a1"), weight: 600, size: 20pt)[Immutable State]]
            ]
          ],
          [#align(center + horizon)[#text(fill: rgb("#666"))[#sym.arrow.b]]],
          [
            #block(
              width: 100%,
              inset: 10pt,
              radius: 8pt,
              fill: rgb("#ddeeff"),
            )[
              #align(center + horizon)[#text(fill: rgb("#1c58a1"), weight: 600, size: 20pt)[Append-Only Log]]
            ]
          ],
          [#align(center + horizon)[#text(fill: rgb("#666"))[#sym.arrow.b]]],
          [
            #block(
              width: 100%,
              inset: 10pt,
              radius: 8pt,
              fill: rgb("#ddeeff"),
            )[
              #align(center + horizon)[#text(fill: rgb("#1c58a1"), weight: 600, size: 20pt)[Reproducible History]]
            ]
          ],
        )
      ],
    )
  ]
]
