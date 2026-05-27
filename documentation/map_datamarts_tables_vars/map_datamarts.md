## DataMarts

Por un lado, La entidad operacionable es el crédito. Por ende, conforma la mínima unidad de granularidad. Por otro lado, la mínima unidad opearativa, que opera con el crédito, es el asesor de créditos. Por ende, representa la mínima unidad de agrupación del crédito. Las demás unidades de agrupación del crédito son agencia y cooperativa. Así, los DataMarts a implementar son:

**gestion_cartera_estrategico**

DataMart referido a la agrupación de créditos desde la mínima unidad de agrupación (asesor). A partir de ello, se podrán construir dashboards estratégicos:

- a nivel de administradores -> que monitorean asesores
- a nivel de gerencia        -> que monitorean agencias

**gestion_cartera_operativo**

DataMart referido a la entidad operacionable (crédito/socio). A partir de ello, se podrán construir dashboards operativos:

- a nivel de asesores -> que monitorean créditos/socios.
