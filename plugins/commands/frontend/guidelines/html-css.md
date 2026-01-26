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
