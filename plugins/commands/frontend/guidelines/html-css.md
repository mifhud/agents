# HTML & CSS Guidelines

## 1. HTML Structure & Semantics

### Document Structure
- Always include `<html>`, `<head>`, and `<body>` tags for valid documents
- Include `lang` attribute on `<html>` tag (e.g., `<html lang="en">`)
- Add essential meta tags in `<head>`:
  - `<meta charset="UTF-8">`
  - `<meta name="viewport" content="width=device-width, initial-scale=1.0">`

### Semantic Elements
- Use semantic HTML elements (`<main>`, `<section>`, `<article>`, `<nav>`, `<header>`, `<footer>`) instead of generic `<div>` containers
- Use `<button>` for actions, `<a>` for navigation—never `<div onclick>`

---

## 2. CSS Guidelines

### Styling Approach
- For single-file artifacts: Use inline `style` attributes or `<style>` blocks in `<head>`
- For complex needs (pseudo-classes, media queries, keyframes): Use `<style>` blocks—inline styles cannot support these

### Animations & Transitions
- Prefer CSS animations over JavaScript (GPU-accelerated, better performance)
- Use `transition` property for smooth state changes
- Define `@keyframes` for complex animations

### Interactive States
- Always define `:hover`, `:focus`, and `:active` states for interactive elements
- Use `:focus-visible` for keyboard-only focus indicators (avoids focus ring on mouse click)

### Best Practices
- Avoid `!important` except when absolutely necessary
- Use CSS custom properties (`--var-name`) for reusable values
- Group related styles and use logical property ordering

## 3. Accessibility (WCAG AA)

### Essential Requirements
- Include `alt` attributes on all images (empty `alt=""` for decorative images)
- Ensure sufficient color contrast:
  - 4.5:1 for normal text
  - 3.1 for large text and UI elements
- All interactive elements must be keyboard-accessible
- Minimum touch target size: 44×44px

### ARIA & Screen Readers
- Use `aria-label` or `aria-labelledby` for interactive elements without visible text
- Provide text alternatives for icon-only buttons

---

## 4. Performance

### Script Loading
- Load external scripts with `defer` or `async` attributes
- Place `<script>` tags at the end of `<body>` or use `defer`
- Wrap initialization code in `DOMContentLoaded` listener

### Images
- Lazy-load images below the fold with `loading="lazy"`

---

## 5. CSS Architecture Methodologies (Use AskQuestionTool/question tool to choose which one to follow)

Understand different CSS organization approaches. Most modern jobs expect familiarity with multiple methodologies.

### Utility-First CSS
A methodology where designs are composed using small, single-purpose classes directly in HTML rather than custom component classes:

```html
<!-- Traditional approach -->
<div class="card">...</div>

<!-- Utility-first approach -->
<div class="flex p-4 bg-white rounded-lg shadow-md">...</div>
```

**Frameworks using this approach:**

| Framework | Notes |
|-----------|-------|
| Tailwind CSS | Most popular, highly configurable |
| UnoCSS | On-demand, extremely fast, Tailwind-compatible |
| Tachyons | One of the earliest, minimal footprint |
| Bootstrap 5 | Hybrid—components plus utility helpers |

**Best practices:**
- Use utilities for layout, spacing, and simple styling
- Extract repeated patterns into components (not more utility classes)
- Configure design tokens in config files for consistency
- Use `@apply` (Tailwind) sparingly—only for highly repeated patterns

**Trade-offs:**
- ✓ Rapid development, no context-switching to CSS files
- ✓ Consistent spacing/colors via design tokens
- ✓ Smaller final CSS (unused styles are purged)
- ✗ Verbose HTML, learning curve for class names

**When to use:** Component-based architectures, rapid prototyping, teams wanting consistent design constraints.

### BEM (Block Element Modifier)
The most widely adopted naming convention for traditional CSS:

- **Block:** Standalone component (`.card`, `.menu`, `.form`)
- **Element:** Part of a block (`.card__title`, `.menu__item`)
- **Modifier:** Variant or state (`.card--featured`, `.menu__item--active`)
- Never nest BEM selectors more than one level deep
- Keep blocks independent and reusable

**Example:**
```css
.card { }
.card__header { }
.card__title { }
.card--highlighted { }
```

**When to use:** Large codebases, teams using Sass/SCSS, projects requiring semantic class names.

### CSS Modules / Scoped CSS
Component-scoped styling for React and Vue ecosystems:

- Styles are locally scoped by default—no naming collisions
- Class names are auto-generated with unique hashes
- Import styles as objects: `import styles from './Button.module.css'`
- Use `composes` for style inheritance between modules
- Combine with CSS variables for theming

**When to use:** React/Vue projects, teams wanting encapsulation without utility classes.

### Choosing a Methodology

| Approach | Best For | Trade-offs |
|----------|----------|------------|
| Utility-First | Speed, consistency, component libs | Verbose HTML, learning curve |
| BEM | Semantic clarity, legacy projects | Manual discipline, more CSS files |
| CSS Modules | Encapsulation, React/Vue apps | Build tooling required |

**General guidance:**
- Learn a utility-first framework
- Know BEM—you'll encounter it in many existing codebases
- Understand scoped CSS concepts—essential for React/Vue work
