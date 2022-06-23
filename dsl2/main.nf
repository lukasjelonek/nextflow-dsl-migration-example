nextflow.enable.dsl=2
params.count=10

process besorgeBrötchen {

  input:
  val count 

  output:
  path "brötchen*" 

  script:
  """
  for i in `seq 1 $count`; do touch brötchen.\$i; done
  """
}

process schneideBrötchenAuf {

  input:
  path broetchen 

  output:
  path "${broetchen}.*en" 

  script:
  """
  touch ${broetchen}.oben
  touch ${broetchen}.unten
  """
}

process schmiereButter{

  input:
  path br 

  output:
  path "${br}.butter" 

  script:
  """
  touch ${br}.butter
  """
}

process schmiereMargarine{

  input:
  path br 

  output:
  path "${br}.margarine" 

  script:
  """
  touch ${br}.margarine
  """
}

process holeSalami {

  input:
  val scheiben 

  output:
  path "*" 

  script:
  """
  for i in `seq 1 $scheiben`; do touch salami.\$i; done
  """
}

process holeKäse {

  input:
  val scheiben 

  output:
  path "*" 

  script:
  """
  for i in `seq 1 $scheiben`; do touch käse.\$i; done
  """
}

process holeSalat {

  input:
  val scheiben 

  output:
  path "*" 

  script:
  """
  for i in `seq 1 $scheiben`; do touch salat.\$i; done
  """
}

process belegeVegetarischeBrötchen {
  
  input:
  file(br)
  file(kaese)
  file(salat) 

  output:
  path "*.belegt" 

  script:
  """
  touch ${br}.${kaese}.${salat}.belegt
  """
}

process belegeSalamiBrötchen {
  
  input:
  file(br)
  file(salami) 

  output:
  path "*.belegt" 

  script:
  """
  touch ${br}.${salami}.belegt
  """
}

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
