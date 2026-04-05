#import "@preview/dati-basati:0.1.0" as db

#layout(avail => context {
  let content = db.er-diagram({
    import db: *
    entity(
      (0, 0),
      label: "visitor",
      name: "visitor",
      attributes: (
        "north": (
          "Name",
          "Requests",
          "Constraints",
        ).rev(),
      ),
    )
    entity(
      (10, 0),
      label: "host",
      name: "host",
      attributes: (
        "north": (
          "Name",
          "Requests",
          "Constraints",
        ).rev(),
      ),
      attributes-position: (
        north: (alignment: center, dir: "rtl"),
      ),
    )
    entity(
      (5, -5),
      label: "meeting",
      name: "meeting",
      attributes: (
        "south": (
          "Time",
          "Place",
        ),
      ),
    )
    relation(
      entities: ("visitor", "meeting"),
      // a visitor can attend multiple meetings, and each meeting can have multiple visitors.
      cardinality: ("(0,n)", "(1,n)"),
    )
    relation(
      entities: ("host", "meeting"),
      // a host can host multiple meetings, but each meeting has exactly one host.
      cardinality: ("(0,n)", "(1,1)"),
    )
  })
  let sz = measure(content)
  let factor = avail.width / sz.width
  box(
    width: avail.width,
    height: sz.height * factor,
    scale(factor * 100%, origin: top + left, content),
  )
})
