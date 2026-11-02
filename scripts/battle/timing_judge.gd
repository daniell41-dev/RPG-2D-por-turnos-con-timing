class_name TimingJudge
extends RefCounted
## Juicio de timing puro: recibe un desfase y la configuración y
## devuelve PERFECTO, BIEN o FALLO. No toca nodos, ni dibuja, ni lee la entrada.

enum Resultado { PERFECTO, BIEN, FALLO }
enum Tipo { ATAQUE, DEFENSA }


## desfase_us = pulsación − impacto − calibración, en microsegundos.
## Negativo = pulsaste antes del impacto; positivo = después.
static func juzgar(desfase_us: int, config: TimingConfig, tipo: Tipo) -> Resultado:
	var distancia_ms: float = absf(desfase_us / 1000.0)
	if distancia_ms <= ventana_perfecto_ms(config, tipo):
		return Resultado.PERFECTO
	if distancia_ms <= ventana_bien_ms(config, tipo):
		return Resultado.BIEN
	return Resultado.FALLO


static func ventana_perfecto_ms(config: TimingConfig, tipo: Tipo) -> float:
	if tipo == Tipo.ATAQUE:
		return config.ventana_perfecto_ataque_ms
	return config.ventana_perfecto_defensa_ms


static func ventana_bien_ms(config: TimingConfig, tipo: Tipo) -> float:
	if tipo == Tipo.ATAQUE:
		return config.ventana_bien_ataque_ms
	return config.ventana_bien_defensa_ms


## Nombre legible de un resultado, para textos en pantalla.
static func nombre(resultado: Resultado) -> String:
	match resultado:
		Resultado.PERFECTO:
			return "Perfecto"
		Resultado.BIEN:
			return "Bien"
		_:
			return "Fallo"
