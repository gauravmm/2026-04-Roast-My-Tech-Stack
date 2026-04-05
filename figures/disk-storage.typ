#block(
  fill: black,
  inset: (x: .5em, y: 0.75em),
  radius: 4pt,
)[
  #set text(fill: luma(220), size: 0.85em)
  #raw(
    block: true,
    "sqlite> SELECT * FROM data;
┌──────────┬───┬─────────────────────────┐
│  bucket  │ v │           data          │
├──────────┼───┼─────────────────────────┤
│ visitors │ 1 │ [{\"name\": \"Alice\", …}   │
│ hosts    │ 1 │ [{\"name\": \"Bob\", …}]    │
│ meetings │ 1 │ [{\"time\": \"9am\", …}]    │
│ meetings │ 2 │ [{\"time\": \"10am\", …}]   │
│ …        │ … │ …                       │
└──────────┴───┴─────────────────────────┘",
  )
]
