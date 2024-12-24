@export()
type Identity = {
  @description('Type of managed service identity')
  type: 'None' | 'SystemAssigned' | 'SystemAssigned, UserAssigned' | 'UserAssigned'
}

@export()
type FunctionAppConfiguration = {
  sku: {
    name: string //'Y1'
    tier: string //'Dynamic'
  }

  @description('App Framework and version')
  teckStack: 'DOTNETCORE|8.0' | 'DOTNETCORE|7.0' | 'JAVA|17-java17' | 'TOMCAT|10.0-java17' | 'TOMCAT|9.0-java17' | 'TOMCAT|8.5-java17' | 'JAVA|11-java11' | 'JBOSSEAP|7-java11' | 'TOMCAT|10.0-java11' | 'TOMCAT|9.0-java11' | 'TOMCAT|8.5-java11' | 'JAVA|8-java8' | 'JBOSSEAP|7-java8' | 'TOMCAT|10.0-java8' | 'TOMCAT|9.0-java8' | 'TOMCAT|8.5-java8' | 'NODE|18-lts' | 'NODE|16-lts' | 'NODE|14-lts' | 'PHP|8.2' | 'PHP|8.1' | 'PHP|8.0' | 'PYTHON|3.12'  | 'PYTHON|3.11' | 'PYTHON|3.10' | 'PYTHON|3.9' | 'PYTHON|3.8' | 'PYTHON|3.7' | 'RUBY|2.7' | 'DOCKER|NGINX'

  @description('The language worker runtime to load in the function app.')
  worker_runtime: 'node' | 'dotnet' | 'java'

  @description('Type of application being monitored.')
  application_type: 'other' | 'web'

  @description('Specifies the OS used for the Azure Function hosting plan.')
  osType: 'Windows' | 'Linux'

  identity: Identity
}
