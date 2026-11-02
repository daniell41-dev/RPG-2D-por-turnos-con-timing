class_name TimingConfig
extends Resource
## Configuración de las ventanas de timing.
## Los valores reales viven en res://resources/config/timing_config.tres;
## aquí solo se declara qué campos existen.

@export_group("Ataque")
## Mitad de la ventana de Perfecto en ataque (± ms alrededor del impacto).
@export var ventana_perfecto_ataque_ms: float
## Mitad de la ventana de Bien en ataque (± ms alrededor del impacto).
@export var ventana_bien_ataque_ms: float
## Tiempo que tarda el círculo en cerrarse hasta el impacto.
@export var duracion_cierre_ataque_ms: float

@export_group("Defensa")
## Mitad de la ventana de Perfecto en defensa (± ms).
@export var ventana_perfecto_defensa_ms: float
## Mitad de la ventana de Bien en defensa (± ms).
@export var ventana_bien_defensa_ms: float

@export_group("Juguete de timing")
## Pausa entre un impacto y el siguiente cierre en la escena de prueba.
@export var pausa_juguete_ms: float
