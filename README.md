# Flutter Lab 10 — Cloud Product Explorer & Detail Carousel

Product catalog that loads live data from `https://fakestoreapi.com/products`.

- **Feed** — loading spinner, `ListView.separated` with thumbnails, titles, ratings and prices, pull-to-refresh.
- **Error state** — offline, timeout (10 s), 404 and 500 each get their own message and a working "Retry Connection" button.
- **Detail screen** — `Hero` image transition, swipeable `PageView.builder` carousel with animated dots and a `1 / 3` counter,
  category badge, full description, sticky "Add to Cart" bar.
- **Share sheet** — modal bottom sheet with the deep link `narxoz://store/product/{id}` and a copy button.

If a pull-to-refresh fails, the list on screen stays and a SnackBar shows the reason.

The API has a single photo per product, so the carousel shows it three ways: the whole product,
a close-up of the top and a close-up of the bottom. The deep link is displayed and copied;
the `narxoz://` scheme is not registered with the OS. "Add to Cart" shows a confirmation only, there is no cart screen in this lab.

## Run

```bash
flutter pub get
flutter run
```

```bash
flutter test
```

## Airplane mode test

1. Turn on Airplane mode and start the app: the error screen appears.
2. Turn Airplane mode off and tap **Retry Connection**: the feed loads without restarting the app.

## Project structure

```
lib/
├── main.dart
├── models/product.dart               # Product + fromJson with null and num safety
├── services/product_service.dart     # http.get, 10 s timeout, status codes, error messages
├── screens/
│   ├── product_feed_screen.dart      # loading / success / error
│   └── product_detail_screen.dart    # details + sticky Add to Cart
└── widgets/
    ├── error_view.dart               # Retry Connection
    ├── photo_carousel.dart           # PageView.builder, dots, counter, Hero
    ├── product_image.dart            # Image.network with loading and error states
    ├── product_tile.dart             # feed row, Hero source
    ├── rating_row.dart
    └── share_link_sheet.dart         # deep link + copy
test/
├── product_test.dart                 # JSON parsing
├── product_service_test.dart         # 200, 404, 500, bad body, offline, timeout
└── app_flow_test.dart                # UI states, retry, carousel, share sheet
```

## Live demo

https://r1nlary.github.io/flutter-lab10-product-explorer/ — built and deployed by `.github/workflows/pages.yml` on every push to `main`.
