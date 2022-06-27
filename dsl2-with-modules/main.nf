nextflow.enable.dsl=2
params.count=10

process legeBrötchenAufEinTablett {

  input:
  path veg 
  path carn 

  output:
  path "tablett"

  script:
  """
  mkdir tablett
  cp $veg $carn tablett/
  """
}

include { besorgeBrötchen } from "./modules/holen"
include { holeSalami } from "./modules/holen"
include { holeSalat } from "./modules/holen"
include { holeKäse } from "./modules/holen"
include { schneideBrötchenAuf } from "./modules/zubereiten"
include { schmiereButter } from "./modules/zubereiten"
include { schmiereMargarine } from "./modules/zubereiten"
include { belegeSalamiBrötchen } from "./modules/zubereiten"
include { belegeVegetarischeBrötchen } from "./modules/zubereiten"

workflow bereitePlatteVor {
  take:
    broetchenAnzahl

  main:
    brötchen = besorgeBrötchen(broetchenAnzahl).flatten() 
    salami = holeSalami(broetchenAnzahl).flatten()
    salat = holeSalat(broetchenAnzahl).flatten()
    käse = holeKäse(broetchenAnzahl).flatten()

    brötchenhälften = schneideBrötchenAuf(brötchen).flatten()
    aufgeteilt = brötchenhälften
      .branch{ 
        veg: it.name.endsWith("oben")
        carn: it.name.endsWith("unten")
      }

    schmiereButter(aufgeteilt.carn)
    belegeSalamiBrötchen(schmiereButter.out, salami)

    schmiereMargarine(aufgeteilt.veg)
    belegeVegetarischeBrötchen(schmiereMargarine.out, käse, salat)

    legeBrötchenAufEinTablett(
      belegeSalamiBrötchen.out.toList(), 
      belegeVegetarischeBrötchen.out.toList()) 
    legeBrötchenAufEinTablett.out
      .subscribe{f -> f.copyTo("tisch/" + f.name)}

  emit:
    legeBrötchenAufEinTablett.out
}

workflow {
  bereitePlatteVor(params.count)
}