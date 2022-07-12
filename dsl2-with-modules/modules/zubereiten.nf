
process schneideBrötchenAuf {

  input:
  path broetchen 

  output:
  path "${broetchen}.*en" , emit: alle
  path "${broetchen}.oben", emit: oben
  path "${broetchen}.unten", emit: unten

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
