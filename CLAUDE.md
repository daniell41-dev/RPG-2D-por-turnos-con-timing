# Proyecto: RPG 2D por turnos con timing (título provisional)

RPG 2D en pixel art con combate por turnos basado en timing: pulsar en el momento justo aumenta el daño causado o reduce el recibido. Dos protagonistas: Nina (gata, espada y daga, daño cuerpo a cuerpo) y Dante (gato, mago de apoyo).

Referencias: Chrono Trigger y Sea of Stars (estructura y tono), Clair Obscur: Expedition 33 (timing).

## Fase actual

Prototipo de combate con formas grises. La especificación es la fuente de verdad:

@docs/prototipo_combate.md

El diseño narrativo y el lore viven en un proyecto de claude.ai, no en este repositorio. No implementes nada narrativo salvo que la especificación lo pida.

## Sobre mí

- Es mi primer juego y trabajo solo.
- Mi experiencia programando: soy programador web (React, Angular, Next.js y algo de Java con Spring Boot). **Ninguna experiencia** en desarrollo de videojuegos ni en Godot.
- Cuando aparezca un concepto propio de Godot o de videojuegos (nodos, escenas, señales, `_process`, Resources, hit-stop…), explícalo la primera vez y, si ayuda, compáralo con algo del mundo web (por ejemplo: señales ≈ eventos/listeners, escenas ≈ componentes, Resources ≈ archivos de configuración tipados).
- Explícame qué haces y por qué, en lenguaje simple.
- Quiero que tú escribas todo el código. Si necesitas que instale o configure algo (en mi equipo o en este entorno), dímelo con pasos concretos.
- Al terminar cualquier cambio, dime exactamente cómo probarlo en el editor de Godot: qué escena abrir, qué pulsar y qué debería pasar.

## Stack

- Godot 4.x: confirma la versión exacta en `project.godot` antes de escribir código.
- GDScript con tipado estático (`var vida: int = 100`, `func atacar() -> void:`). No C#.
- No instales addons ni plugins sin preguntarme.

## Reglas de trabajo

- **Pasos pequeños.** Sigue el plan por pasos de la especificación. Antes de cada paso, dame tu plan en pocas líneas (archivos y para qué sirve cada uno) y espera mi OK. No avances al siguiente paso hasta que yo haya probado el anterior.
- **No añadas nada fuera de la especificación.** Si crees que falta algo o que algo está mal diseñado, dímelo y pregunta; no lo decidas tú.
- **Lógica separada de presentación.** La lógica de combate no toca nodos visuales: emite señales y la presentación las escucha.
- **Números en Resources (`.tres`)**, nunca escritos a mano en el código.
- **Escenas `.tscn` mínimas.** Crea los nodos de interfaz desde código cuando sea razonable. Si editas un `.tscn` a mano, que sea simple, y verifica que carga.
- **Timing:** mide con `Time.get_ticks_usec()`, lee la entrada en `_input` o `_unhandled_input`, y nunca cuentes frames.
- **Entradas por Input Map**, no con teclas fijas en el código.
- **Nombres:** archivos y variables en `snake_case`, clases en `PascalCase`. Comentarios en español.
- **Git:** cuando un paso funcione, propón un mensaje de commit corto en español.
- Si Godot está disponible en la terminal, úsalo en modo headless para comprobar que el proyecto abre sin errores de script antes de decirme que algo está listo.
