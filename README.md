## Streamify Pro

A Flutter application for streaming, games, and curated content with multi-language support (English/Arabic).

### Key Features
- Home, Streaming, Games, Kids, Fitness, Search, and Chatbot modules
- Authentication flow with login and signup
- Favorites and Watch Later lists (local persistence)
- Global chatbot FAB shown after authentication
- Localization: English and Arabic with in-app language switcher
- Legal pages: Terms and Conditions, Privacy Policy (both localized)

### Project Structure
- `lib/app.dart`: App entry (theme, localization, providers, routes)
- `lib/config/routes.dart`: Centralized route names and generator
- `lib/screens/**`: Screens grouped by feature (auth, home, streaming, games, kids, fitness, search, chatbot, legal)
- `lib/widgets/**`: Reusable UI (navigation, common widgets, auth components)
- `lib/providers/**`: State management (Provider)

### Legal Pages
- Screens:
  - `lib/screens/legal/terms_screen.dart`
  - `lib/screens/legal/privacy_policy_screen.dart`
- Routes (navigate with `Navigator.pushNamed`):
  - Terms: `/legal/terms`
  - Privacy: `/legal/privacy`
- Entry points:
  - Footer links on `LoginScreen`
  - Links in Account modal (`SideDrawer` → Account)
- Localization:
  - All headings and body text localized via `t(context, en:, ar:)`
  - AppBar titles are localized
- Licensing statement:
  - Both pages explicitly state that all content is licensed and used under appropriate permissions

### Localization
- Files: `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`
- Runtime language switching via `LanguageSwitcher` and `LanguageProvider`
- On the login screen, the language switcher is positioned above content to ensure it remains tappable

### Development
See `SETUP.md` for environment setup, running, and building.

Common commands:

```bash
flutter pub get
flutter run
flutter build apk --release
```

### Navigation Reference
Key named routes defined in `lib/config/routes.dart`:
- Auth: `/auth/login`, `/auth/signup`
- Main: `/home`, `/streaming`, `/games`, `/kids`, `/fitness`, `/search`, `/chatbot`
- Legal: `/legal/terms`, `/legal/privacy`

### Notes
- Directionality (LTR/RTL) adapts based on the selected language.
