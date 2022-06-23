nextflow.enable.dsl=1
params.count=10

Channel.from(params.count).set{ch_brCount}
Channel.from(params.count).set{ch_käsCount}
Channel.from(params.count).set{ch_salCount}
Channel.from(params.count).set{ch_salatCount}

process besorgeBrötchen {

  input:
  val count from ch_brCount

  output:
  file "brötchen*" into ch_br

  script:
  """
  for i in `seq 1 $count`; do touch brötchen.\$i; done
  """

}

process schneideBrötchenAuf {

  input:
  file broetchen from ch_br.flatten()

  output:
  file "${broetchen}.*en" into ch_cb

  script:
  """
  touch ${broetchen}.oben
  touch ${broetchen}.unten
  """
}

Channel.create().set{ch_veg_br}
Channel.create().set{ch_carn_br}

ch_cb.flatten().choice(ch_veg_br, ch_carn_br) {br -> br.name.endsWith("oben") ? 1: 0}


process schmiereButter{

  input:
  file br from ch_carn_br

  output:
  file "${br}.butter" into ch_carn_br_but

  script:
  """
  touch ${br}.butter
  """
}

process schmiereMargarine{

  input:
  file br from ch_veg_br

  output:
  file "${br}.margarine" into ch_veg_br_marg

  script:
  """
  touch ${br}.margarine
  """
}

process holeSalami {

  input:
  val scheiben from ch_salCount

  output:
  file "*" into ch_sal

  script:
  """
  for i in `seq 1 $scheiben`; do touch salami.\$i; done
  """
}

process holeKäse {

  input:
  val scheiben from ch_käsCount

  output:
  file "*" into ch_käse

  script:
  """
  for i in `seq 1 $scheiben`; do touch käse.\$i; done
  """
}

process holeSalat {

  input:
  val scheiben from ch_salatCount

  output:
  file "*" into ch_salat

  script:
  """
  for i in `seq 1 $scheiben`; do touch salat.\$i; done
  """
}

process belegeVegetarischeBrötchen {
  
  input:
  set file(br), file(kaese), file(salat) from ch_veg_br_marg.merge(ch_käse.flatten(), ch_salat.flatten())

  output:
  file "*.belegt" into ch_veg_br_bel

  script:
  """
  touch ${br}.${kaese}.${salat}.belegt
  """


}

process belegeSalamiBrötchen {
  
  input:
  set file(br), file(salami) from ch_carn_br_but.merge(ch_sal.flatten())

  output:
  file "*.belegt" into ch_carn_br_bel

  script:
  """
  touch ${br}.${salami}.belegt
  """
}

process legeBrötchenAufEinTablett {

  publishDir "tisch/", mode: "copy"

  input:
  file veg from ch_veg_br_bel.toList()
  file carn from ch_carn_br_bel.toList()

  output:
  file "tablett"

  script:
  """
  mkdir tablett
  cp $veg $carn tablett/
  """
}
