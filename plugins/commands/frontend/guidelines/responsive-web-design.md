# Responsive Web Design: Screen Size Reference Guide

A comprehensive reference for screen sizes and breakpoints used in modern responsive web design.

---

## Large Displays

| Display Type | Resolution |
|--------------|------------|
| 4K (Ultra HD) | 3840 × 2160px |
| 2K (QHD) | 2560 × 1440px |
| Full HD | 1920 × 1080px |

---

## Desktop

| Category | Width Range |
|----------|-------------|
| Large Desktop | 1440px and above |
| Standard Desktop | 1024px – 1440px |

---

## Tablets

| Orientation | Width Range |
|-------------|-------------|
| Landscape | 1024px – 1280px |
| Portrait | 768px – 1024px |

---

## Mobile Devices

| Device Size | Width Range |
|-------------|-------------|
| Large Phones | 425px – 768px |
| Medium Phones | 375px – 425px |
| Small Phones | 320px – 375px |

---

## Common CSS Framework Breakpoints

Standard breakpoints used by popular frameworks like Bootstrap and Tailwind CSS:

| Name | Abbreviation | Min-Width |
|------|--------------|-----------|
| Extra Small | xs | 0 – 575px |
| Small | sm | 576px |
| Medium | md | 768px |
| Large | lg | 992px |
| Extra Large | xl | 1200px |
| Extra Extra Large | xxl | 1400px |

---

## Best Practices

### Focus on Key Breakpoints
Most designs focus on 3–5 key breakpoints rather than targeting every possible screen size. Prioritize the devices most relevant to your audience.

### Mobile-First Design
Start with styles for small screens and progressively add complexity using `min-width` media queries. This approach ensures a solid baseline experience for all users.

### Handling 4K Displays
For ultra-wide and 4K displays, cap content width at around 1400–1600px to maintain readability. Allowing content to stretch across the full screen can harm the user experience.

### Minimum Width Testing
Always test your designs at 320px width to ensure compatibility with the smallest phones still in active use.

---

## Quick Reference: Media Query Examples

```css
/* Mobile-first approach */

/* Small devices (phones, 576px and up) */
@media (min-width: 576px) { }

/* Medium devices (tablets, 768px and up) */
@media (min-width: 768px) { }

/* Large devices (desktops, 992px and up) */
@media (min-width: 992px) { }

/* Extra large devices (large desktops, 1200px and up) */
@media (min-width: 1200px) { }

/* Extra extra large devices (1400px and up) */
@media (min-width: 1400px) { }
```

---

*Last updated: January 2026*