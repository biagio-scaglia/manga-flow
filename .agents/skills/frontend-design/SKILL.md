---
name: frontend-design
description: Architecture, token management, component composition, typography scales, theme coherence, and responsive layout standards for Flutter and modern frontend systems.
---

# Frontend Design: Component Architecture & Token Discipline

## Design System Tokens
1. **Single Source of Truth**:
   - Colors, Radii, Typography, Spacing, and Elevations must live exclusively in token registries (`AppColors`, `AppTypography`, `AppRadii`, `AppSpacing`).
   - Zero magic numbers or ad-hoc `Color(0x...)` in presentation widgets.
2. **Dual-Theme Rigor (Night Ink / Paper Cream)**:
   - Light mode is not just inverted white; it is rich cream paper (`#F7F4EE`), deep sumi ink (`#1A1715`), and subdued borders (`#E2DCCF`).
   - Dark mode is authentic dark room ink (`#0F0E0D`), soft off-white text (`#EDE8DF`), and crisp hairline borders (`#292522`).
3. **Component Hierarchy & Scalability**:
   - Atomic design: Atoms (Badges, Buttons, Stamps) -> Molecules (ListTiles, Cards, Steppers) -> Organisms (Hero Editorial, Matrices) -> Templates/Screens.
   - Decoupled widgets: Presentation widgets receive data or value objects and emit callbacks, never touching raw network or storage directly.
4. **Responsive Layouts**:
   - Dynamic grid columns based on available width (`MediaQuery.sizeOf(context).width`).
   - Graceful adaptation between compact mobile and large screen / tablet viewports without awkward stretched cards.
