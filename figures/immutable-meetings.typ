#import "@preview/cetz:0.4.2"

#layout(avail => {
  let dx = 2.8 // new list shifted right (causing overlap)
  let dy = 0.5 // new list shifted down

  let item-h = 0.5
  let item-w = 2.0
  let pad = 0.125

  let old-items = (
    ("M₁", rgb("#eeeeee"), true),
    ("M₂", rgb("#eeeeee"), true),
    ("M₃", rgb("#eeeeee"), true),
    ("M₄", rgb("#ffdddd"), false),
    ("M₅", rgb("#eeeeee"), true),
    ("M₆", rgb("#ffdddd"), false),
    ("M₇", rgb("#eeeeee"), true),
    ("M₈", rgb("#ffdddd"), false),
  )
  let new-items = (
    ("M₁", rgb("#eeeeee"), true),
    ("M₂", rgb("#eeeeee"), true),
    ("M₃", rgb("#eeeeee"), true),
    ("M₅", rgb("#eeeeee"), true),
    ("M₇", rgb("#eeeeee"), true),
    ("M₉", rgb("#ddffdd"), false),
    ("M₁₀", rgb("#ddffdd"), false),
    ("M₁₁", rgb("#ddffdd"), false),
  )

  let n = old-items.len()
  let list-h = n * item-h + 2 * pad
  let list-w = item-w + 2 * pad

  // Total canvas extents: x in [0, dx+list-w], y in [0.4, -(dy+list-h+0.7)]
  let total-w = dx + list-w

  cetz.canvas(length: avail.width / total-w, {
    import cetz.draw: *

    let draw-list(ox, oy, label, items) = {
      rect(
        (ox, oy),
        (ox + list-w, oy - list-h),
        fill: white,
        stroke: 1.2pt,
      )
      content(
        (ox + list-w / 2, oy + 0.3),
        text(size: 0.7em, weight: "bold", label),
      )
      for (i, item) in items.enumerate() {
        let (name, fill, is-muted) = item
        let y = oy - pad - i * item-h - item-h / 2
        rect(
          (ox + pad, y - item-h / 2 + 0.08),
          (ox + pad + item-w, y + item-h / 2 - 0.08),
          fill: fill,
          stroke: if is-muted { (paint: gray, dash: "dashed", thickness: 0.6pt) } else { 0.6pt },
        )
        content(
          (ox + pad + item-w / 2, y),
          text(size: 0.65em, fill: if is-muted { gray } else { black }, name),
        )
      }
    }

    // Old list first (behind), new list on top (overlapping, shifted down-right)
    draw-list(0, 0, "meetings (old)", old-items)
    draw-list(dx, -dy, "meetings (new)", new-items)

    // Line from center of old block's east edge to center of new block's west edge
    let old-mid-y = -list-h / 2
    let new-mid-y = -(dy + list-h / 2)
    let f = 0.12 // shorten each end by this fraction
    let x1 = list-w + f * (dx - list-w)
    let y1 = old-mid-y + f * (new-mid-y - old-mid-y)
    let x2 = dx - f * (dx - list-w)
    let y2 = new-mid-y - f * (new-mid-y - old-mid-y)
    line(
      (x1, y1),
      (x2, y2),
      mark: (end: ">"),
      stroke: (paint: luma(160), thickness: 2pt),
    )
    content(
      ((list-w + dx) / 2, (old-mid-y + new-mid-y) / 2),
      box(fill: white, inset: 2pt, text(size: 0.8em)[Δ]),
    )
  })
})
