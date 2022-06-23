
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

