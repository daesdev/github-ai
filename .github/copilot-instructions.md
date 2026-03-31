---
name: Reglas de Proyecto
description: Instrucciones para commits y PRs
---

# Reglas para Mensajes de Commit

- Usa el formato Conventional Commits (feat ✨, fix 🐛, etc.).
- Formato: `<type>(<scope>): <emoji> <subject>`

## Types permitidos

- **feat ✨**: Nuevas funcionalidades
- **fix 🐛**: Corrección de bugs
- **chore 🔧**: Tareas de mantenimiento
- **refactor 🛠️**: Refactorización de código
- **docs 📝**: Documentación
- **style 🎨**: Estilos (formateo)
- **test ✅**: Pruebas
- **build 📦**: Build y dependencias
- **ci 👷**: Configuración de CI/CD
- **perf ⚡**: Optimizaciones de rendimiento

## Ejemplos

- `feat(ui): ✨ Add floating contact button`
- `fix(api): 🐛 Resolve user data fetch timeout`
- `docs: 📝 Update README installation steps`
- `refactor: 🛠️ Simplify authentication flow`
- `chore: 🔧 Update dependencies`

## Reglas adicionales

- **Scope**: Área afectada (ui, api, layout, content), en minúsculas
- **Subject**: Imperativo, claro, máximo 72 caracteres, sin punto al final
- **Body**: Explica el POR QUÉ (no el CÓMO). Deja línea en blanco después del título
- **Footer**: Para breaking changes o issues. Ejemplo: `Closes #123`

## Casos especiales

Si hay cambios no relacionados, usa un solo título y agrega al final:

```
NOTE: staged changes include unrelated work; consider splitting commits.
```

---

# Reglas para Pull Requests

- Incluye siempre una sección de "Cambios clave".
- Título en imperativo, menos de 50 caracteres.
- Descripción siguiendo estructura What/Why/How.

## Estructura de PR

### Título
- Usa el modo imperativo (ej: "Add feature" no "Added feature")
- Mantén menos de 50 caracteres
- Se específico sobre qué cambió

### Descripción

**Cambios clave**: Qué se modificó
- Lista las principales modificaciones
- Explica el propósito de cada cambio

**Por qué**: Problema que resuelve
- Describe el problema que se está resolviendo
- Referencia issues relacionados (ej: `Fixes #123`, `Closes #456`)

**Cómo probar**: Instrucciones de testing
- Proporciona instrucciones paso a paso
- Incluye los resultados esperados

**Notas adicionales** (opcional):
- Breaking changes
- Dependencias agregadas/eliminadas
- Cambios de configuración necesarios
- PRs o documentación relacionada
