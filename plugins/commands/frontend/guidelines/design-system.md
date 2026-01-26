Create a complete design system style guide for [BRAND/PRODUCT NAME] that serves as the single source of truth for designers and developers. The guide should be practical, scannable, and implementation-ready.

1. Foundation: Visual Principles
Define 3–5 core design principles that guide all visual decisions. For each principle, provide a name and tagline, a 2–3 sentence explanation of what it means in practice, and a concrete example of how it manifests in the UI.

2. Typography System
Type Scale:
Create a modular type scale with named tokens (e.g., display-xl, heading-lg, body-md, caption-sm). For each level, specify font-family, font-size (px and rem), line-height, letter-spacing, and font-weight.
Usage Guidelines:
Define which type styles to use for headings (h1–h6), body copy, UI labels, buttons, form inputs, helper text, and error messages. Include maximum line lengths for readability.

3. Color Tokens
Semantic Color System:
Define tokens organized by purpose rather than hue—

Brand colors: primary, secondary, accent
Neutral palette: background, surface, border, text (with light/dark variants)
Feedback colors: success, warning, error, info
Interactive states: default, hover, active, focus, disabled

For each token, provide the hex value, accessibility contrast ratio against common backgrounds, and when to use it.

4. Spacing System
Define a spacing scale based on a base unit (e.g., 4px or 8px). Provide named tokens (space-xs through space-3xl) with pixel values. Include guidance on when to use each spacing value—component padding, element gaps, section margins, and page gutters.

5. Grid & Layout System
Specify the number of columns (e.g., 12), gutter widths, margin widths, and breakpoints for mobile, tablet, and desktop. Include container max-widths and rules for how layouts should adapt across breakpoints.

6. UI Components
For each core component (buttons, inputs, cards, modals, navigation, tabs, tooltips, badges, alerts), document the following: anatomy diagram with labeled parts, available variants (size, style, type), required and optional props, spacing and sizing specs, and example usage code snippets.

7. Interactive States
Define the visual treatment for each state across all interactive elements—default, hover, focus (keyboard), active/pressed, disabled, loading, error, and success. Specify what changes (color, shadow, border, scale, opacity) and include timing/easing for transitions.

8. Accessibility Guidelines
Include minimum contrast ratios (WCAG AA/AAA), focus indicator requirements, touch target sizes (minimum 44×44px), required ARIA labels and roles, keyboard navigation patterns, motion/animation considerations (reduced motion support), and screen reader announcement guidance.

9. Others
...

Last Number. Do's and Don'ts
For each major section, provide 3–5 visual examples of correct implementation (Do) paired with common mistakes (Don't). Cover typography pairing errors, color misuse, spacing inconsistencies, component misapplication, and accessibility violations.


Output Format
Structure the guide with a table of contents linking to each section, visual examples and swatches inline, code snippets for token implementation (CSS variables, Tailwind config, or design tool format), and a quick-reference cheat sheet at the end.

Tone: Authoritative but approachable. Write for a mixed audience of designers and developers. Prioritize clarity and scannability over exhaustive prose.