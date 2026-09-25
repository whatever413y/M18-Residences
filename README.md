# M18 Residences

A Flutter-based application for bill tracking and electric consumption.

## Features

- Bill tracking
- Electric consumption

## Getting Started

1. **Clone the repository:**

    ```bash
    git clone https://github.com/whatever413y/m18_residences.git
    ```

2. **Configure the API URL:** copy `.env.example` to `.env` (repo root) and adjust `API_URL`. It is compiled in with
   `--dart-define-from-file=.env`; without it the app stops at startup with a clear `API_URL is not set` error.

3. **Shared package:** models, the API client and common widgets come from `m18_shared`
   ([shared-packages](https://github.com/whatever413y/shared-packages), pinned by tag in `pubspec.yaml`).
   To work against a local checkout next to this repo, add a `pubspec_overrides.yaml` (gitignored):

    ```yaml
    dependency_overrides:
      m18_shared:
        path: ../shared-packages/packages/m18_shared
    ```

4. **Install dependencies:**

    ```bash
    flutter pub get
    ```

5. **Run or build the app:**

    ```bash
    flutter run -d chrome --dart-define-from-file=.env
    flutter build web --release --dart-define-from-file=.env
    ```

Browser e2e tests (the `shared-e2e` repo) build with `--dart-define=E2E=true`, which keeps Flutter's accessibility tree on.
They find the account ID field, the submit button and the latest bill's total by the semantics ids `tenant-account-id`,
`tenant-login-submit` and `tenant-latest-total`.

## Project Structure

- `lib/` - Main application code
- `assets/` - Images and other assets
