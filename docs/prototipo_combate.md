# Prototipo de combate — especificación v0.1

**Objetivo:** comprobar que el combate por turnos con timing se siente bien, antes de invertir en arte.
Todo se hace con formas de colores (rectángulos, círculos). **Esto no es el juego**: es una prueba.

Todos los números de este documento son **puntos de partida para ajustar**. Viven en Resources (`.tres`), nunca escritos a mano en el código.

---

## 1. Preguntas que el prototipo tiene que responder

1. ¿Da gusto pulsar a tiempo? Esto depende del hit-stop, la vibración de pantalla y el sonido.
2. ¿Las ventanas de timing son justas, ni regaladas ni imposibles?
3. ¿Filo y Brasa crean una decisión real, o una opción domina siempre?
4. ¿Se entiende la diferencia entre Cubrir y Potenciar sin explicarla?

## 2. Alcance

**Entra:**
- Nina y Dante contra 1 o 2 enemigos.
- Timing ofensivo y defensivo.
- Filo, Brasa, Potenciar, Cubrir y Convicción.
- Dos tipos de enemigo y tres encuentros predefinidos.
- Calibración de latencia.
- Panel de depuración.
- Sonidos provisionales.

**No entra:** inventario, objetos, equipo, niveles o experiencia, mapas, exploración, diálogos, guardado de partida, arte final, música, huir.

## 3. Por qué existen estas mecánicas (intención de diseño)

El tema del juego es que **la fuerza no está en ser perfecto, sino en seguir en pie con las grietas**. Por eso:
- **Filo** premia la perfección pero es frágil: se pierde al recibir un golpe.
- **Brasa** premia lo contrario: fallar y seguir. Además sirve de ayuda para jugadores con menos reflejos.
- **Cubrir** expresa que Dante solo es valiente cuando protege a alguien.
- **Potenciar** es la habilidad más útil de Dante. En el juego final esconde un costo narrativo; en el prototipo solo se cuenta en el panel de depuración.

Si al implementar algo una decisión técnica contradice esta intención, pregunta antes de decidir.

## 4. Controles

| Acción | Teclado | Mando |
|---|---|---|
| Confirmar / timing (ataque y defensa) | Espacio o Z | A / Cruz |
| Cancelar / volver en menú | X o Escape | B / Círculo |
| Panel de depuración | F1 | — |
| Reiniciar encuentro | F5 | — |

**Un solo botón** sirve para todo el timing. La entrada se define en el Input Map de Godot, no con teclas fijas en el código.

## 5. Flujo de combate

- **Orden de turnos fijo:** Nina, luego Dante, luego cada enemigo en orden. No hay sistema de velocidad.
- En su turno, cada personaje elige en un menú simple:
  - **Nina:** Atacar · Corte doble (si tiene 3 de Filo o más) · Resistir (si la Brasa está llena)
  - **Dante:** Atacar · Potenciar · Cubrir · Resistir (si la Brasa está llena)
- Los enemigos eligen objetivo al azar: **60 % Nina, 40 % Dante**. Si Dante está cubriendo, todo ataque a Nina le llega a Dante.
- Un personaje con 0 de vida queda fuera hasta que acabe el combate.
- **Victoria:** todos los enemigos en 0. Pantalla simple con "Repetir" y "Otro encuentro".
- **Derrota:** Nina y Dante en 0. Pantalla simple con "Repetir".

## 6. Timing

### Cómo se mide
- La entrada se lee en `_input` o `_unhandled_input`, nunca en `_physics_process`.
- El momento de la pulsación se marca con `Time.get_ticks_usec()`.
- Cada golpe tiene un **momento de impacto** calculado en microsegundos: el inicio de la animación más la duración del amago.
- El desfase es `pulsación − impacto − calibración`. **Nunca se cuentan frames.**
- La lógica de juicio va en un script puro (`timing_judge.gd`): recibe el desfase y la configuración, y devuelve `PERFECTO`, `BIEN` o `FALLO`. No toca nodos ni animaciones.

### Ataque (timing ofensivo)
- Al atacar aparece un círculo que se cierra sobre el objetivo. El momento justo es cuando el círculo coincide con el borde del objetivo; ese es el impacto.
- Duración del cierre: 600 ms.

| Resultado | Ventana | Multiplicador de daño | Extra |
|---|---|---|---|
| Perfecto | ±60 ms | ×1,5 | Nina +1 Filo |
| Bien | ±140 ms | ×1,0 | — |
| Fallo (fuera de ventana o no pulsar) | — | ×0,7 | +15 de Brasa |

### Defensa (timing defensivo)
- El enemigo hace un amago visible (el rectángulo crece o cambia de color) con un sonido de aviso, luego se lanza. El impacto es el instante en que llega.
- Hay una opción "Ayuda visual de defensa" (activable en el panel de depuración) que muestra un círculo que se cierra también en defensa. Sirve para probar si el amago se lee sin ayuda.

| Resultado | Ventana | Daño recibido | Extra |
|---|---|---|---|
| Perfecto | ±70 ms | 0 % | Nina +1 Filo · Dante +1 Convicción si está cubriendo |
| Bien | ±160 ms | 50 % | — |
| Fallo | — | 100 % | +25 de Brasa · si es Nina, pierde **todo** el Filo |

### Anti-machaque
Si el jugador pulsa **antes** de que se abra la ventana de Bien, queda bloqueado durante 250 ms para ese golpe. Si el bloqueo cubre el impacto, el golpe cuenta como Fallo.

## 7. Recursos y habilidades

### Filo (solo Nina)
- Rango de 0 a 5.
- Cada carga añade +10 % al daño de Nina.
- Gana +1 por cada Perfecto de Nina, ofensivo o defensivo.
- Vuelve a 0 con un Fallo defensivo de Nina. Un Bien no gana ni pierde Filo.
- **Corte doble:** cuesta 3 de Filo. Son dos golpes, cada uno con su propio timing ofensivo y ×1,2 de daño base cada uno.

### Brasa (compartida por el grupo)
- Rango de 0 a 100.
- Gana +15 por cada Fallo ofensivo y +25 por cada Fallo defensivo, de cualquiera de los dos personajes.
- **Resistir:** cuesta 100 y la puede usar cualquiera de los dos en su turno.
  - Cura el 30 % de la vida máxima a ambos (también levanta a un personaje caído con el 30 %).
  - El próximo golpe enemigo contra cada uno se resuelve como Perfecto automático.

### Potenciar (Dante sobre Nina)
- Los próximos 2 ataques de Nina hacen +30 % de daño.
- Suma +1 a un contador `marcas` que solo se ve en el panel de depuración y no tiene efecto en el juego. Prepara una mecánica narrativa posterior.

### Cubrir y Convicción (Dante)
- **Cubrir:** hasta el siguiente turno de Dante, todo ataque dirigido a Nina lo recibe Dante, que se defiende con timing normal.
- **Convicción:** rango de 0 a 3. Gana +1 por cada Perfecto defensivo de Dante mientras cubre.
- El siguiente ataque de Dante consume toda la Convicción: +25 % de daño por punto.

## 8. Daño

- **Daño de un ataque aliado** = ATQ × multiplicador de timing × (1 + 0,10 × Filo, solo Nina) × (1,3 si está Potenciada) × (1 + 0,25 × Convicción consumida, solo Dante).
- **Daño de un ataque enemigo** = ATQ del enemigo × porcentaje de la tabla de defensa.
- Se redondea al entero más cercano. No hay estadística de defensa en el prototipo.

## 9. Datos iniciales

| Personaje | Vida | Ataque | Notas |
|---|---|---|---|
| Nina | 100 | 12 | Espada y daga. Rectángulo negro |
| Dante | 80 | 14 (mágico) | Mago. Rectángulo gris claro |
| Soldado de la Orden | 60 | 10 | Un golpe. Amago de 700 ms |
| Cazador de la Orden | 90 | 8 por golpe | Combo de 3 golpes con ritmo irregular: 400 ms, 250 ms y 550 ms entre impactos |

Los golpes de cada enemigo se definen en su Resource como una lista (amago, intervalos), para poder crear enemigos nuevos sin código.

### Encuentros predefinidos
Se eligen desde un menú de depuración.
1. Un Soldado (tutorial).
2. Dos Soldados.
3. Un Cazador y un Soldado.

## 10. Calibración de latencia

- Una escena aparte con un metrónomo: sonido y destello cada 750 ms.
- El jugador pulsa al ritmo 10 veces. Se promedia el desfase y se guarda como `calibracion_ms`, con un rango de ±150 ms, en `user://config.cfg`.
- Ese valor se resta en todos los juicios de timing.
- Hay un botón para volver a 0.

## 11. Respuesta sensorial (feel)

- **Perfecto:** hit-stop (pausa breve) de 70 ms, vibración de pantalla leve, sonido propio y texto emergente "¡Perfecto!".
- **Bien:** sonido normal y texto "Bien".
- **Fallo:** sonido sordo y texto "Fallo".
- **Sonidos provisionales:** tonos simples generados por código, o archivos `.wav` que el autor pondrá en `assets/sfx/`. El código no debe romperse si faltan los archivos.

## 12. Panel de depuración (F1)

Muestra:
- El último desfase en ms con su resultado (por ejemplo, `+34 ms → Perfecto`).
- Filo, Brasa, Convicción y `marcas`.
- Las ventanas de timing actuales.
- El valor de calibración.
- El interruptor de "Ayuda visual de defensa".

## 13. Estructura sugerida en Godot

```
res://
  scenes/battle/battle.tscn
  scenes/tools/timing_toy.tscn
  scenes/tools/calibration.tscn
  scripts/battle/battle_manager.gd     # flujo de turnos (máquina de estados), sin nada visual
  scripts/battle/timing_judge.gd       # juicio de timing puro
  scripts/battle/combatant.gd          # vida, Filo, Convicción, estados
  scripts/battle/battle_presenter.gd   # todo lo visual: formas, círculos, textos, hit-stop
  scripts/data/                        # clases de Resource: timing_config, character_data, enemy_data
  resources/config/timing_config.tres
  resources/characters/nina.tres, dante.tres
  resources/enemies/soldado.tres, cazador.tres
  assets/sfx/
  docs/
```

**Regla:** `battle_manager` emite señales y `battle_presenter` las escucha. Así, cuando las formas se cambien por sprites, la lógica no se toca.

## 14. Plan por pasos

Cada paso termina con algo que se puede probar en el editor. **No se pasa al siguiente sin que el autor lo pruebe.**

1. **Juguete de timing y calibración.** Crear la estructura de carpetas, `timing_judge.gd` y `timing_config`. Una escena con un círculo que se cierra en bucle: al pulsar muestra el desfase en ms y el resultado. Después, la escena de calibración.
   *Prueba:* pulsar 20 veces y ver que los resultados coinciden con lo que se siente.
2. **Combate mínimo.** Nina contra un Soldado: ataque y defensa con timing, vida, victoria y derrota.
   *Prueba:* ganar y perder a propósito.
3. **Dante.** Añadir Dante, Potenciar, Cubrir y Convicción.
   *Prueba:* que Cubrir desvíe los golpes y que la Convicción suba solo con Perfectos mientras cubre.
4. **Filo y Brasa.** Añadir Corte doble y Resistir.
   *Prueba:* que Filo se pierda con un Fallo defensivo y que la Brasa se llene fallando.
5. **Cazador, encuentros y feel.** Combo irregular, menú de encuentros, panel de depuración completo, hit-stop, vibración y sonidos.
   *Prueba:* los tres encuentros, de principio a fin.

## 15. Cómo se evalúa el prototipo

Hacer que 3 a 5 personas que no sean el autor jueguen los tres encuentros. Anotar:
- Qué porcentaje de Perfecto, Bien y Fallo sacan.
- Si entienden Cubrir y Potenciar sin explicación.
- Si usan Resistir.
- Qué dicen espontáneamente.

Con esos datos se ajustan las ventanas y los números en los `.tres`, y se vuelve al documento de diseño si algo de fondo no funciona.
