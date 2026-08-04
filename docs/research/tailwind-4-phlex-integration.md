# Research: Tailwind 4 + Phlex Integration in Rails 8

> Researched 2026-08-04 against primary sources.  
> Resolves: [GitHub issue #3](https://github.com/everyfutureyou/neurodiversity/issues/3)

---

## Summary

Tailwind CSS v4 (current stable: v4.3.x) and Phlex v2 are both production-ready and integrate cleanly with Rails 8. The combination does not require any special adapter gem — standard `tailwindcss-rails` (v4.x) and `phlex-rails` (v2.x) are all that is needed. The biggest architectural shift is Tailwind 4's move to a **CSS-first configuration** (`@theme` directive instead of `tailwind.config.js`), which is actually *more* compatible with Phlex's pure-Ruby class-string approach than the JavaScript config was. Multi-theme (light/dark/custom) is well-supported via `@custom-variant` and CSS custom properties.

---

## 1. Gems and Adapters

### `phlex-rails` (v2.4.0, latest as of Jan 2026)

- **Source**: [github.com/yippee-fun/phlex-rails](https://github.com/yippee-fun/phlex-rails)
- **RubyGems**: [rubygems.org/gems/phlex-rails](https://rubygems.org/gems/phlex-rails) — 3 million+ downloads
- **Requires**: Ruby ≥ 3.2; works with any Rails version that supports standard view rendering
- Provides an object-oriented alternative to ActionView: components live in `app/components` (under the `Components::` namespace) and views live in `app/views` (under the `Views::` namespace), both set up by the install generator.
- Ships with **adapters for all built-in Rails view helpers** (`Phlex::Rails::Helpers::Routes`, `Phlex::Rails::Helpers::LinkTo`, etc.) — none are included by default to keep components lean.
- No built-in Tailwind adapter is needed; Phlex writes regular HTML `class=` attributes from Ruby strings, which Tailwind scans like any other template.

### `tailwindcss-rails` (v4.6.0, latest as of Jun 2026)

- **Source**: [github.com/rails/tailwindcss-rails](https://github.com/rails/tailwindcss-rails)
- The official Rails gem. v4.x ships against Tailwind CLI v4 via `tailwindcss-ruby` (the platform-specific binary gem). No Node.js or npm is required for the basic setup.
- Input file moved from `app/assets/stylesheets/application.tailwind.css` to **`app/assets/tailwind/application.css`** in v4 of the gem.
- Output: `app/assets/builds/tailwind.css` — compiled and included by the asset pipeline.
- Hooks into `assets:precompile` and `test:prepare` automatically; Puma plugin available for live rebuild without Foreman.

### No separate `tailwind-phlex` adapter needed

There is no official "tailwind-phlex" gem and none is required. Tailwind 4 scans source files as plain text, and `.rb` files in `app/components` and `app/views` are included in the scan automatically (they are not in `.gitignore` and not binary). Class strings in Phlex Ruby code are detected the same way they are in ERB templates.

---

## 2. Installation in a Rails 8 App

```bash
# 1. Add both gems
bundle add tailwindcss-rails phlex-rails

# 2. Install Tailwind (creates app/assets/tailwind/application.css, Procfile.dev, etc.)
bin/rails tailwindcss:install

# 3. Install Phlex (creates app/components/components/base.rb, app/views/views/base.rb, etc.)
bin/rails generate phlex:install

# 4. Start development server with live CSS rebuild
bin/dev
```

Sources:
- [Tailwind Rails guide](https://tailwindcss.com/docs/installation/framework-guides/ruby-on-rails)
- [Phlex getting started](https://www.phlex.fun/introduction/getting-started.html)
- [tailwindcss-rails README](https://github.com/rails/tailwindcss-rails)

---

## 3. Tailwind 4's CSS-First Architecture

### `@theme` replaces `tailwind.config.js`

In v4, all design tokens are defined in CSS using the `@theme` directive rather than a JavaScript config file. This is a **breaking change** from v3.

```css
/* app/assets/tailwind/application.css */
@import "tailwindcss";

@theme {
  --color-brand-500: oklch(0.62 0.23 259);
  --font-display: "Satoshi", sans-serif;
  --breakpoint-3xl: 120rem;
}
```

Every `@theme` variable is automatically:
1. Emitted as a CSS custom property on `:root`
2. Mapped to a utility class (e.g. `--color-brand-500` → `bg-brand-500`, `text-brand-500`, etc.)

Source: [tailwindcss.com/docs/theme](https://tailwindcss.com/docs/theme)

### `tailwind.config.js` still loadable but deprecated

JavaScript configs are no longer auto-detected. Load one explicitly if needed:

```css
@config "../../tailwind.config.js";
```

Source: [Tailwind v4 upgrade guide — JavaScript config](https://tailwindcss.com/docs/upgrade-guide#using-a-javascript-config-file)

### Key v3 → v4 breaking changes affecting Rails/Phlex usage

| Area | v3 | v4 |
|------|----|----|
| Import | `@tailwind base; @tailwind utilities;` | `@import "tailwindcss";` |
| PostCSS package | `tailwindcss` | `@tailwindcss/postcss` |
| Config | `tailwind.config.js` (auto-detected) | `@theme {}` in CSS (JS config must be explicit) |
| Custom utilities | `@layer utilities { .foo {} }` | `@utility foo {}` |
| Theme function | `theme(colors.red.500)` | `var(--color-red-500)` |
| Ring default | 3px | 1px |
| Shadow scale | `shadow-sm` was small, `shadow` was default | `shadow-xs`, `shadow-sm` (renamed) |
| Hover on mobile | Always triggers | Only when `hover: hover` media matches |
| Prefix syntax | `tw-flex` | `tw:flex` |

Source: [Tailwind v4 upgrade guide](https://tailwindcss.com/docs/upgrade-guide)

---

## 4. Tailwind 4 Class Scanning with Phlex

Tailwind v4 auto-scans every file in the project that is not in `.gitignore`, not binary, and not a CSS/lock file. Ruby files in `app/components/**/*.rb` and `app/views/**/*.rb` are scanned automatically with no configuration.

**Critical constraint (identical to v3):** Tailwind treats source files as plain text. It cannot interpret Ruby string interpolation. Class names must be **spelled out completely**:

```ruby
# BAD — Tailwind will not detect "bg-red-500" or "bg-green-500"
div(class: "bg-#{color}-500") { ... }

# GOOD — both strings are statically detectable
COLORS = { error: "bg-red-500", success: "bg-green-500" }
div(class: COLORS[state]) { ... }
```

For dynamic variant-heavy components, use a lookup hash at the top of the class (or a separate constants module). Source: [tailwindcss.com/docs/detecting-classes-in-source-files](https://tailwindcss.com/docs/detecting-classes-in-source-files)

If a class is assembled only at runtime and cannot appear statically, safelist it:

```css
/* app/assets/tailwind/application.css */
@source inline("bg-red-{100,200,300,400,500,600,700,800,900}");
```

---

## 5. Multi-Theme Architecture with Tailwind 4 + Phlex

### Dark mode

By default, Tailwind 4's `dark:` variant uses `@media (prefers-color-scheme: dark)`. Override it with a class-based or data-attribute-based selector for a togglable theme:

```css
/* Class-based dark mode */
@custom-variant dark (&:where(.dark, .dark *));

/* Or data-attribute-based (preferred for multi-theme) */
@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
```

Source: [tailwindcss.com/docs/dark-mode](https://tailwindcss.com/docs/dark-mode)

Then in a Phlex component:

```ruby
class Components::Card < Components::Base
  def view_template
    div(class: "bg-white dark:bg-gray-800 text-gray-900 dark:text-white") { ... }
  end
end
```

Set the theme on `<html>`:

```ruby
# In the layout view (a Phlex view):
html(data: { theme: current_theme }) { ... }  # "light", "dark", or "custom"
```

### Custom themes (beyond light/dark)

Define additional `@custom-variant` selectors per theme:

```css
@import "tailwindcss";

@custom-variant dark    (&:where([data-theme=dark], [data-theme=dark] *));
@custom-variant high-contrast (&:where([data-theme=hc], [data-theme=hc] *));

@theme {
  /* Base tokens (light theme) */
  --color-surface: oklch(0.99 0 0);
  --color-on-surface: oklch(0.15 0 0);
  --color-primary: oklch(0.62 0.23 259);
}
```

Override tokens per theme with CSS variable reassignment:

```css
[data-theme=dark] {
  --color-surface: oklch(0.15 0 0);
  --color-on-surface: oklch(0.95 0 0);
  --color-primary: oklch(0.75 0.18 259);
}

[data-theme=hc] {
  --color-surface: #000;
  --color-on-surface: #fff;
  --color-primary: #ffff00;
}
```

**Important:** `@theme` variables are always generated as `:root` CSS variables. Per-theme overrides use regular `:root`-level or selector-scoped CSS variable reassignment — *not* `@theme`, which is only for design-token-to-utility-class mappings.

Source: [tailwindcss.com/docs/dark-mode#using-a-data-attribute](https://tailwindcss.com/docs/dark-mode#using-a-data-attribute)

### Using semantic tokens in Phlex components

Because `@theme` variables are exposed as CSS custom properties, components reference them via standard Tailwind utilities:

```ruby
class Components::Button < Components::Base
  def view_template
    # Uses --color-primary via bg-primary utility (if defined in @theme)
    button(class: "bg-primary text-on-surface rounded-md px-4 py-2 hover:opacity-90") { yield }
  end
end
```

Or via arbitrary values with CSS variables when a utility doesn't exist:

```ruby
div(class: "bg-(--color-surface) text-(--color-on-surface)") { ... }
```

---

## 6. Recommended Component Library Architecture

### Base component

```ruby
# app/components/components/base.rb
class Components::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  # include other helpers as needed
end
```

### Variant lookup pattern (Tailwind-safe)

```ruby
# app/components/components/button.rb
class Components::Button < Components::Base
  VARIANTS = {
    primary:   "bg-primary text-white hover:opacity-90",
    secondary: "bg-transparent border border-primary text-primary hover:bg-primary/10",
    danger:    "bg-red-600 text-white hover:bg-red-700",
  }.freeze

  SIZES = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-6 py-3 text-lg",
  }.freeze

  def initialize(variant: :primary, size: :md, **attrs)
    @variant = variant
    @size = size
    @attrs = attrs
  end

  def view_template(&block)
    button(
      class: "#{VARIANTS[@variant]} #{SIZES[@size]} rounded-md font-medium transition-opacity",
      **@attrs,
      &block
    )
  end
end
```

### Kits for namespaced component sets

Phlex supports [Kits](https://www.phlex.fun/components/kits.html) — a way to group related components under a namespace and render them with a clean DSL:

```ruby
# Usage in a view
render Components::Card.new do |card|
  card.header { "Title" }
  card.body { "Content" }
end
```

### Theming with data attributes in layout

```ruby
# app/views/views/layouts/application.rb
class Views::Layouts::Application < Views::Base
  def view_template
    doctype
    html(data: { theme: helpers.current_theme }) do
      head { ... }
      body { yield }
    end
  end
end
```

---

## 7. Plugins

Tailwind plugins (e.g. `@tailwindcss/typography`, `daisyui`) require a `package.json` alongside the Rails app. Install via npm or Yarn, then reference in the CSS file:

```css
@import "tailwindcss";
@plugin "daisyui";
@plugin "@tailwindcss/typography";
```

Source: [tailwindcss-rails README — Using Tailwind plugins](https://github.com/rails/tailwindcss-rails#using-tailwind-plugins)

Note: PostCSS is no longer supported by the Tailwind CLI in v4. To use PostCSS with Tailwind 4, switch to `cssbundling-rails` with `@tailwindcss/postcss`. Source: [tailwindcss-rails README — Using with PostCSS](https://github.com/rails/tailwindcss-rails#using-with-postcss)

---

## 8. Known Issues and Gotchas

| Issue | Detail |
|-------|--------|
| `sassc-rails` conflict | Remove `sassc-rails` from Gemfile; it cannot parse modern CSS syntax ([source](https://github.com/rails/tailwindcss-rails#conflict-with-sassc-rails)) |
| Class scanning scope | `tailwindcss-rails` v4 runs the CLI from the Rails root; all non-gitignored `.rb` files are scanned automatically |
| Programmatic class composition | Must use complete class strings or lookup tables — no string interpolation |
| Browser support | Tailwind 4 requires Safari 16.4+, Chrome 111+, Firefox 128+; drop v3 only if browser targets allow |
| `watchman` conflict | Known issue: `tailwindcss -w` hangs when `watchman` is installed ([upstream issue](https://github.com/tailwindlabs/tailwindcss/issues/17246)) |
| `@theme` vs `:root` | `@theme {}` defines design-token-to-utility mappings; per-theme runtime overrides must use plain `:root` or scoped CSS variables, not `@theme` |

---

## 9. Decision Recommendation for Neurodiversity School

1. **Stack**: `tailwindcss-rails` v4 + `phlex-rails` v2 — no other adapters needed.
2. **Theme architecture**: Use `data-theme` attribute on `<html>` with `@custom-variant` per theme (light/dark minimum; extensible to high-contrast or brand themes). Define semantic tokens (`--color-surface`, `--color-primary`, etc.) in `@theme`; override them per theme via selector-scoped CSS variables.
3. **Component library**: One `Components::Base < Phlex::HTML` with `Routes` helper included; build individual components with frozen `VARIANTS` and `SIZES` hashes to keep class names statically detectable.
4. **i18n note**: No Tailwind-specific i18n considerations; RTL support may require Tailwind's `rtl:` variant if needed.

---

## Sources

| Resource | URL |
|----------|-----|
| Phlex home | https://www.phlex.fun/ |
| Phlex getting started | https://www.phlex.fun/introduction/getting-started.html |
| Phlex Rails helpers | https://www.phlex.fun/rails/helpers.html |
| Phlex Rails views | https://www.phlex.fun/rails/views.html |
| phlex-rails on RubyGems | https://rubygems.org/gems/phlex-rails |
| phlex-rails on GitHub | https://github.com/yippee-fun/phlex-rails |
| tailwindcss-rails on GitHub | https://github.com/rails/tailwindcss-rails |
| Tailwind v4 upgrade guide | https://tailwindcss.com/docs/upgrade-guide |
| Tailwind theme variables | https://tailwindcss.com/docs/theme |
| Tailwind dark mode | https://tailwindcss.com/docs/dark-mode |
| Tailwind class detection | https://tailwindcss.com/docs/detecting-classes-in-source-files |
| Tailwind Rails guide | https://tailwindcss.com/docs/installation/framework-guides/ruby-on-rails |
