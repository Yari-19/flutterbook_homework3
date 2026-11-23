# FlutterBook

CS 4381 FlutterBook is a Flutter application with appointments, contacts,
notes, tasks, and SQLite-backed expenses.

## Expenses

The Expenses tab displays saved titles, amounts, categories, dates, and payment
methods. Category icons identify each row, amounts use two decimal places, and
an empty database displays **No expenses yet**.

Use Add to create an expense, tap a row to edit it, or slide a row to reveal
Delete. Deletion requires confirmation. The entry form requires a nonempty
title and a positive finite amount, and supports a category, payment method,
date, and optional description. Cancel discards unsaved form values.

`ExpensesModel` uses the shared `BaseModel` for list loading, screen selection,
and persistence. `ExpensesDBWorker` maps `Expense` objects to SQLite rows in
`expenses.db`. Dates are stored as Unix milliseconds and displayed in U.S.
English. The application configures SQLite FFI on Windows.

## Run the application

Install Flutter with Dart compatible with the constraint in `pubspec.yaml` and
the platform tools for your target device. From the project directory, run:

```sh
flutter pub get
flutter run
```

## Generate API documentation

From the project directory, install Dartdoc and generate the static site.
These PowerShell commands derive the SDK paths from Flutter on your PATH:

```powershell
flutter pub get
dart pub global activate dartdoc 9.0.8
$flutterSdk = Split-Path (Split-Path (Get-Command flutter).Source -Parent) -Parent
$env:FLUTTER_ROOT = $flutterSdk
dart pub global run dartdoc --sdk-dir "$flutterSdk/bin/cache/dart-sdk" --output doc/api
```

On Windows, Flutter plugin setup may require Developer Mode for symlink support.

The generated site starts at `doc/api/index.html`. It documents the project's
public APIs, including the Expenses widgets, model, and database worker.

## Preview or deploy the documentation

Serve the generated directory with a static HTTP server. For example, with
Python installed:

```sh
python -m http.server 8000 --bind 127.0.0.1 --directory doc/api
```

Open <http://127.0.0.1:8000/> to browse the API pages and search.

The separate `flutterbook-dartdoc.zip` contains only the generated website.
Extract it, then run the following command from the extracted directory:

```sh
python -m http.server 8000 --bind 127.0.0.1
```

To deploy, upload the extracted files to any static web host, preserving the
directory structure and using `index.html` as the root page. The documentation
does not require Flutter, SQLite, or an application server at runtime.
