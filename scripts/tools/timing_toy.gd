extends Node2D
## Juguete de timing: un anillo se cierra en bucle sobre un círculo objetivo.
## Al pulsar "confirmar" se muestra el desfase en ms y el juicio.
## Es una herramienta de prueba, no parte del combate.

# Tamaños y colores: solo presentación, no afectan al juicio.
const RADIO_OBJETIVO: float = 40.0
const RADIO_INICIAL_ANILLO: float = 180.0
const GROSOR_ANILLO: float = 4.0
const COLOR_FONDO: Color = Color(0.12, 0.12, 0.12)
const COLOR_OBJETIVO: Color = Color(0.5, 0.5, 0.5)
const COLOR_ANILLO: Color = Color(0.92, 0.92, 0.92)
const COLORES_RESULTADO: Dictionary = {
	TimingJudge.Resultado.PERFECTO: Color(1.0, 0.85, 0.2),
	TimingJudge.Resultado.BIEN: Color(0.6, 0.9, 0.6),
	TimingJudge.Resultado.FALLO: Color(0.9, 0.4, 0.4),
}
const MAX_HISTORIAL: int = 10

@export var config: TimingConfig

var _inicio_us: int = 0           # instante en que arrancó el bucle
var _calibracion_us: int = 0      # se leerá de user://config.cfg cuando exista la calibración
var _historial: Array[String] = []
var _etiqueta_resultado: Label
var _etiqueta_historial: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(COLOR_FONDO)
	_crear_interfaz()
	_inicio_us = Time.get_ticks_usec()


func _process(_delta: float) -> void:
	# Solo pedimos redibujar; la posición del anillo se calcula con el reloj, no con frames.
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirmar"):
		# Lo primero: marcar el instante de la pulsación.
		var pulsacion_us: int = Time.get_ticks_usec()
		_juzgar_pulsacion(pulsacion_us)
		get_viewport().set_input_as_handled()


func _draw() -> void:
	var centro: Vector2 = get_viewport_rect().size / 2.0
	draw_circle(centro, RADIO_OBJETIVO, COLOR_OBJETIVO)

	var transcurrido_us: int = (Time.get_ticks_usec() - _inicio_us) % _periodo_us()
	var cierre_us: int = _cierre_us()
	if transcurrido_us < cierre_us:
		var progreso: float = float(transcurrido_us) / float(cierre_us)
		var radio: float = lerpf(RADIO_INICIAL_ANILLO, RADIO_OBJETIVO, progreso)
		draw_arc(centro, radio, 0.0, TAU, 96, COLOR_ANILLO, GROSOR_ANILLO, true)


func _juzgar_pulsacion(pulsacion_us: int) -> void:
	var impacto_us: int = _impacto_mas_cercano_us(pulsacion_us)
	var desfase_us: int = pulsacion_us - impacto_us - _calibracion_us
	var resultado: TimingJudge.Resultado = TimingJudge.juzgar(desfase_us, config, TimingJudge.Tipo.ATAQUE)

	var texto: String = "%+d ms → %s" % [roundi(desfase_us / 1000.0), TimingJudge.nombre(resultado)]
	_etiqueta_resultado.text = texto
	_etiqueta_resultado.add_theme_color_override("font_color", COLORES_RESULTADO[resultado])

	_historial.push_front(texto)
	if _historial.size() > MAX_HISTORIAL:
		_historial.pop_back()
	_etiqueta_historial.text = "\n".join(_historial)


## Instante (µs) del impacto más cercano a la pulsación.
## El impacto número k ocurre en: inicio + k × periodo + duración del cierre.
func _impacto_mas_cercano_us(pulsacion_us: int) -> int:
	var desde_primer_impacto: float = float(pulsacion_us - _inicio_us - _cierre_us())
	var k: int = maxi(0, roundi(desde_primer_impacto / float(_periodo_us())))
	return _inicio_us + k * _periodo_us() + _cierre_us()


func _cierre_us() -> int:
	return roundi(config.duracion_cierre_ataque_ms * 1000.0)


func _periodo_us() -> int:
	return _cierre_us() + roundi(config.pausa_juguete_ms * 1000.0)


func _crear_interfaz() -> void:
	var ayuda := Label.new()
	ayuda.text = "Pulsa Espacio / Z cuando el anillo toque el borde del círculo.\nPerfecto ±%d ms · Bien ±%d ms" % [
		roundi(config.ventana_perfecto_ataque_ms), roundi(config.ventana_bien_ataque_ms)]
	ayuda.position = Vector2(24, 24)
	add_child(ayuda)

	_etiqueta_resultado = Label.new()
	_etiqueta_resultado.add_theme_font_size_override("font_size", 40)
	_etiqueta_resultado.position = Vector2(24, get_viewport_rect().size.y - 80)
	add_child(_etiqueta_resultado)

	_etiqueta_historial = Label.new()
	_etiqueta_historial.position = Vector2(get_viewport_rect().size.x - 220, 24)
	add_child(_etiqueta_historial)
