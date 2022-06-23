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

workflow{
  brötchen = besorgeBrötchen(params.count).flatten() 
  salami = holeSalami(params.count).flatten()
  salat = holeSalat(params.count).flatten()
  käse = holeKäse(params.count).flatten()

  brötchenhälften = schneideBrötchenAuf(brötchen).flatten()
  aufgeteilt = brötchenhälften
    .branch{ 
      veg: it.name.endsWith("oben")
      carn: it.name.endsWith("unten")
    }

  schmiereButter(aufgeteilt.carn)
  belegeSalamiBrötchen(schmiereButter.output, salami)

  schmiereMargarine(aufgeteilt.veg)
  belegeVegetarischeBrötchen(schmiereMargarine.output, käse, salat)

  legeBrötchenAufEinTablett(
    belegeSalamiBrötchen.output.toList(), 
    belegeVegetarischeBrötchen.output.toList()) 
  legeBrötchenAufEinTablett.output
    .subscribe{f -> f.copyTo("tisch/" + f.name)}
}
