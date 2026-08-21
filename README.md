# JellySpoon

Playful watercolor kitchen for logging scoops. Local only. No account.

**Bundle ID:** `com.jellyspoon.kitchen`  
**iOS 17+**, iPhone portrait, Swift 6.2, Health & Fitness.

## Architecture

MVP + Coordinator. XIBs only (no storyboards, no SwiftUI). `UIPageViewController` swipe for Today / Bites / Picnic plan / Wish jars / Aims. Plan days are a nested 7-page swipe.

Short names: `LogMgr`, `ScanVC`, `MealPg`, `WishPr`, `SeekVC`, `ItemVC`, `SlotVC`, `AppCoord`. Flat sources. Vendored `DigitGrab` (EAN/QR digits, UPC-12 → `0` + code). Persistence: Documents plist + UserDefaults via `LogMgr`.

Slots: **Sunrise bowl** / **Lunch picnic** / **Supper pot** / **Treat** (Treat only in eaten, never on the plan).

Default aims: 2150 / 98 / 248 / 68.

## Unique features

VoiceOver labels/hints, Dynamic Type, high-contrast toggle, hit targets ≥ 56 pt. `UIPageViewController` swipe across Today / Bites / Picnic plan / Wish jars / Aims. Vendored `DigitGrab`. Treat is eaten-only. Plan is a nested 7-page swipe.

## How it differs

MVP + Coordinator + XIBs only. Watercolor kitchen. Not a glass tray, neon arcade, oak pantry, civic desk, or pulse grid.

## Accessibility

VoiceOver labels and hints on controls, Dynamic Type (Patrick Hand + `UIFontMetrics`), high-contrast toggle, hit targets ≥ 56 pt. Custom watercolor art for visuals; SF Symbols only as VoiceOver / high-contrast fallback.

## Build

```bash
xcodegen generate
xcodebuild -scheme JellySpoon -destination 'platform=iOS Simulator,name=iPhone 16' -sdk iphonesimulator CODE_SIGNING_ALLOWED=NO build
```

Open Food Facts: `JellySpoon/1.0 (iOS; com.jellyspoon.kitchen; health-fitness tracker)`.

Font: Patrick Hand (SIL OFL) in `JellySpoon/Fonts/` + `LICENSE`.

## Image prompts

Watercolor children's picture-book, soft wet edges, bright saturated candy colors, no text.

| Asset | Prompt |
|---|---|
| AppIcon | Chubby smiling wooden spoon dripping strawberry jelly in a sunny yellow bowl, mint-cream wash |
| SplashArt | Morning kitchen table, spoon character waving, pink/yellow/teal jelly jars |
| BootA | Spoon opening a candy-pink kitchen door with a jelly doorknob |
| BootB | Recipe cards flying as if swiped, spoon surfing a raspberry jelly wave |
| BootC | Spoon with candy magnifying glass over jelly-stripe barcode on a jam jar |
| BootD | Giant candy buttons and a smiling cloud ear, high-contrast sun/moon badges |
| EmptyBowl | Hopeful empty ceramic bowl, one jelly drip, lonely spoon |
| EmptyJar | Empty wooden shelf with dust-bunny jellybean creatures |
| EmptyPicnic | Empty gingham blanket under a candy tree, dashed jelly basket |
| SlotSunrise | Sunrise cereal bowl, berries, oats, jelly sun |
| SlotPicnic | Picnic basket, sandwich, lemonade, noon sun |
| SlotSupper | Bubbling pot, carrots, steam, evening window |
| SlotTreat | Cupcake with strawberry-jelly swirl and wobbly cherry |
| PackOats | Berry oatmeal jar with smiling oat face |
| PackEgg | Two smiling sunny-side-up eggs |
| PackCheese | Picnic cheese wedge with hole-face |
| PackSoup | Garden soup, carrot coins, pea smile |
| PackApple | Crunch apple, jelly leaf, tiny worm friend |
| PackCocoa | Cocoa puff cloud in a purple bowl |
| PackToast | Toast wearing a jelly blanket |
| PackFizz | Lemon fizz bottle, balloon bubbles |
| TexPaper | Pink/lemon/mint watercolor paper wash only |
| ChromeBtn | Glossy strawberry-jelly oval candy button |
| ChromeFrame | Wavy lime-and-pink jelly picture frame |

Same prompts live in `Assets.xcassets/*/Contents.json` `info.comment`.
